# 尝试包含 .env 文件中的变量（如果文件存在）
-include .env

# build 目标：编译合约
build:; forge build

# 默认参数（可被环境变量或命令行覆盖）
ANVIL_PORT ?= 8545  # 本地 anvil 节点的端口号
ANVIL_ENDPOINT ?= https://eth-mainnet.public.blastapi.io  # anvil fork 的主网 URL


# test 目标：清理构建并运行所有测试
.PHONY: test
test:
	forge clean && forge b && forge t

# cov_summary 目标：生成简洁的覆盖率摘要报告，排除 mocks 和 script 目录
.PHONY: cov_summary
cov_summary:
	forge clean && forge b && forge coverage --no-match-coverage "(mocks|script)" --report summary

# cov_report 目标：清理旧报告，生成新的 lcov 格式覆盖率报告，并用 genhtml 转换为可视化报告
.PHONY: cov_report
cov_report:
	@if [ -d coverage ]; then rm -r coverage; fi  # 删除旧 coverage 目录（如果存在）
	@if [ -d report ]; then rm -r report; fi      # 删除旧 report 目录（如果存在）
	forge clean                                    # 清理构建输出
	forge b                                        # 重新构建
	forge coverage --no-match-coverage "(mocks|script)" --report lcov  # 生成 lcov 格式覆盖率数据
	genhtml lcov.info -o report --branch-coverage --ignore-errors inconsistent  # 生成可视化 HTML 报告

# anvil_start 目标：启动本地 anvil 节点，并 fork 主网
.PHONY: anvil_start
anvil_start:ß
	@echo "Start running anvil node at PORT: ${ANVIL_PORT}"
	anvil --block-time 10 --fork-url $(ANVIL_ENDPOINT) --port $(ANVIL_PORT)

# anvil_fund 目标：给指定账户分配测试 ETH
.PHONY: anvil_fund
anvil_fund:
	@echo "Setting balance to 10_000 ether for: $(DEPLOYER)"
	@curl http://localhost:8545 -X POST -H "Content-Type: application/json" \
		--data '{"method":"anvil_setBalance","params":["$(strip $(DEPLOYER))","0x021e19e0c9bab2400000"],"id":1,"jsonrpc":"2.0"}'
	echo "Current balance of $(DEPLOYER):"
	@cast balance $(DEPLOYER)


# 定义目录和文件集合
SRC_DIR := src  # 合约源代码目录
FLATTEN_DIR := flatten  # 扁平化后的输出目录
ABI_DIR := abis  # ABI 输出目录
OUT_DIR := out/  # forge 编译输出目录
SOL_FILES := $(shell find $(SRC_DIR) -type f -name "*.sol")  # 所有 .sol 文件
JSON_FILES := $(wildcard $(OUT_DIR)/**/*.json)  # 所有编译生成的 JSON 文件

# generate_docs 目标：生成文档
.PHONY: generate_docs
generate_docs:
	@echo "Generating documents..."
	forge doc --build

# flatten 目标：将所有合约文件扁平化输出
.PHONY: flatten
flatten: $(FLATTEN_DIR)

# 实际的扁平化过程
$(FLATTEN_DIR):
	mkdir -p $(FLATTEN_DIR)
	@for file in $(SOL_FILES); do \
		echo "Flattening $$file..."; \
		forge flatten $$file --output $(FLATTEN_DIR)/$$(basename $$file); \
	done

# abi 目标：提取 ABI 并保存为 json 文件
abi:
	@forge build --silent
	@mkdir -p $(ABI_DIR)
	@for f in $(SOL_FILES); do \
		contract_name=$$(basename $$f); \
		contract_name=$$(echo $$contract_name | cut -d. -f1); \
		json_file="$(OUT_DIR)/$$contract_name.sol/$$contract_name.json"; \
		if [ -f "$$json_file" ]; then \
			jq '.abi' "$$json_file" > "$(ABI_DIR)/$$contract_name.json"; \
		else \
			echo "abi not found for $$contract_name."; \
		fi; \
	done


# clean 目标：删除构建生成的目录
.PHONY: clean
clean:
	@rm -r broadcast   # 删除部署记录
	@rm -r flatten     # 删除扁平化合约输出
	@rm -r abis        # 删除 ABI 文件
	@rm -r report      # 删除覆盖率报告


# 所有脚本文件
SCRIPTS := $(shell find script -name "*.sol")


# 定义一个部署所有脚本的命令模板（函数式变量）
define deploy_scripts
	@echo "开始批量部署 $(SCRIPTS) 到 $(1)..."
	@if [ -z "$(SCRIPTS)" ]; then \
		echo "没有找到任何 .sol 脚本，请确认目录和文件名"; \
		exit 1; \
	fi
	@for script in $(SCRIPTS); do \
		echo "部署 $$script 到 $(1)..."; \
		forge script $$script \
			--force \
			--slow \
			--gas-estimate-multiplier 200 \
			--broadcast \
			--rpc-url $(2) \
			--private-key $(PRIVATE_KEY) \
			$(if $(3),--verify --etherscan-api-key $(3)); \
	done
endef

# ===================
# 命令目标区域
# ===================
.PHONY: deploy_mainnet
deploy_mainnet:
	$(call deploy_scripts,Mainnet,$(MAINNET_RPC),$(ETHERSCAN_API_KEY))

.PHONY: deploy_sepolia
deploy_sepolia:
	$(call deploy_scripts,Sepolia,$(SEPOLIA_RPC),$(ETHERSCAN_API_KEY))

.PHONY: deploy_bnb_testnet
deploy_bnb_testnet:
	$(call deploy_scripts,BNB Testnet,$(BSC_TESTNET_RPC),$(BSCSCAN_API_KEY))

.PHONY: deploy_polygon
deploy_polygon:
	$(call deploy_scripts,Polygon,$(POLYGON_RPC),$(POLYGONSCAN_API_KEY))

.PHONY: deploy_arbitrum
deploy_arbitrum:
	$(call deploy_scripts,Arbitrum,$(ARB_RPC),$(ARBISCAN_API_KEY))

.PHONY: deploy_optimism
deploy_optimism:
	$(call deploy_scripts,Optimism,$(OP_RPC),$(OPSCAN_API_KEY))


.PHONY: deploy_local
deploy_all:
	@echo "Deploying contracts... "
	@if [ -z "$(SCRIPTS)" ]; then \
		echo "没有找到任何 .sol 脚本，请确认目录和文件名"; \
		exit 1; \
	fi
	@for script in $(SCRIPTS); do \
		echo "部署 $$script ..."; \
		echo "SCRIPTS = $(SCRIPTS)"; \
		forge script $$script \
			--force \
			--broadcast \
			--rpc-url http://localhost:8545 \
			--private-key $(PRIVATE_KEY) \
	done




# deploy_bnb_testnet 目标：部署合约到 BNB 测试网
.PHONY: deploy_bnb_testnet
deploy_bnb_testnet:
	@echo "Deploying contracts..."
	forge script script/Deploy_BNBTestnet.sol \
		--force \
		--broadcast \
		--slow \
		--rpc-url https://bsc-testnet-rpc.publicnode.com \
		--private-key $(PRIVATE_KEY)

# deploy_sepolia 目标：部署合约到 Sepolia 测试网并验证
.PHONY: deploy_sepolia
deploy_sepolia:
	@echo "Deploying contracts..."
	forge script script/Deploy_Sepolia.s.sol \
		--force \
		--slow \
		--gas-estimate-multiplier 200 \
		--broadcast \
		--rpc-url $(SEPOLIA_RPC) \
		--private-key $(PRIVATE_KEY) \
		--verify \
		--etherscan-api-key $(ETHERSCAN_API_KEY)


# deploy_mainnet 目标：部署合约到主网并验证
.PHONY: deploy_mainnet
deploy_mainnet:
	@echo "Deploying contracts..."
	forge script script/Deploy_Mainnet.s.sol \
		--force \
		--slow \
		--rpc-url ${MAINNET_RPC} \
		--verify \
		--etherscan-api-key ${ETHERSCAN_API_KEY} \
		--private-key $(PRIVATE_KEY) \
		--broadcast

.PHONY: deploy_all
deploy_all:
	@echo "开始递归部署 scripts/ 下所有 .sol 脚本..."
	@if [ -z "$(SCRIPTS)" ]; then \
		echo "没有找到任何 .sol 脚本，请确认目录和文件名"; \
		exit 1; \
	fi
	@for script in $(SCRIPTS); do \
		echo "部署 $$script ..."; \
		echo "SCRIPTS = $(SCRIPTS)"; \
		forge script $$script \
			--force \
			--slow \
			--gas-estimate-multiplier 200 \
			--broadcast \
			--rpc-url $(SEPOLIA_RPC) \
			--private-key $(PRIVATE_KEY) \
			--verify \
			--etherscan-api-key $(ETHERSCAN_API_KEY); \
	done


# deploy 目标：根据指定网络进行部署
.PHONY: deploy
deploy:
	@if [ -z "$(network)" ]; then \
		echo "请指定 network 变量，例如：make deploy network=sepolia"; \
		exit 1; \
	fi; \
	if [ "$(network)" = "local" ]; then \
		$(MAKE) deploy_local; \
	elif [ "$(network)" = "sepolia" ]; then \
		$(MAKE) deploy_all; \
	elif [ "$(network)" = "bnb" ]; then \
		$(MAKE) deploy_bnb_testnet; \
	elif [ "$(network)" = "mainnet" ]; then \
		$(MAKE) deploy_mainnet; \
	else \
		echo "不支持的 network=$(network)，支持值为：local, sepolia, bnb, mainnet"; \
		exit 1; \
	fi

















