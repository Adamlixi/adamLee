---
layout: post
title: "Ankr &  Dune  & The Graph"
---

# 三种区块链数据提供方式

“生态”是这三者中非常重要的一环。

Ankr/Quicknode → API

Dune → SQL

The Graph → GraphQL

目的：了解不同产品的使用场景。

# Ankr

API/RPC 提供商。

## 数据采集方式

共有四种不同的API：

**Basic RPC**

get_blocks

![Untitled](/images/ankrdunegraph/Untitled.png)

**Advanced Developer APIs**

需要将区块链原生数据进行索引，并同步到**数据库**中。

Query API：搜索一定范围的Block中数据的API。

Token API：针对Token的搜索表。

NFT API：针对NFT的搜索表。

![截屏2023-07-11 12.17.05.png](/images/ankrdunegraph/%E6%88%AA%E5%B1%8F2023-07-11_12.17.05.png)

问题：RPC提供商更偏向一个硬件厂商，主要核心竞争力是硬件。机器越多，分布越广提供的服务就会越好。没有核心壁垒。

## Ankr Network

![截屏2023-07-11 11.55.35.png](/images/ankrdunegraph/%E6%88%AA%E5%B1%8F2023-07-11_11.55.35.png)

**节点提供方**：

Archive Nodes：Store an entire copy of the blockchain from the genesis block.

Full Nodes：Hold the complete current state of the blockchain.

Light Nodes：Only store block headers and reference full nodes to seek complete data.

不同节点提供商对硬件的要求也不相同。在检测机器满足要求后，任何人都可以加入到网络中。

## 盈利模式

1.Saas

[https://www.ankr.com/docs/rpc-service/service-plans/](https://www.ankr.com/docs/rpc-service/service-plans/)

[https://www.ankr.com/docs/advanced-api/pricing/](https://www.ankr.com/docs/advanced-api/pricing/)

2.代币经济学：

个人感觉代币的价值主要体现在这个代币可以做什么。

可以看到Ankr在生态方面下了很大的功夫。做各种Web3应用（DEFI，GameFi，Bridge，App Chain…）。

# Dune

## 用户群体

数据分析

## 数据采集方式

数据采集三大核心表：

![截屏2023-07-09 下午12.01.00.png](/images/ankrdunegraph/%E6%88%AA%E5%B1%8F2023-07-09_%E4%B8%8B%E5%8D%8812.01.00.png)

Dune 并没有维护Account表。（因为会涉及到大量更新操作，不好维护）。

导致想要获取Account维度的统计信息会很不方便。

Account维度的工具：

[https://platform.arkhamintelligence.com/](https://platform.arkhamintelligence.com/)

抽象表 or 高级表都是建立在基础表之上。

![截屏2023-07-09 下午12.03.19.png](/images/ankrdunegraph/%E6%88%AA%E5%B1%8F2023-07-09_%E4%B8%8B%E5%8D%8812.03.19.png)

## 表分类

### **原始数据表**

Blocks

Transactions

Event logs

Traces

### **解析表**

**调用表**

可以查看合约调用的方法

projectname_blockchain.contractName_call_functionName

**uniswap_v3."Factory_call_createPool"**

**事件日志**

查看具体合约发出的事件

projectname_blockchain.contractName_evt_eventName

`uniswap_v3_ethereum.Factory_evt_PoolCreated`

### 抽象表

**行业数据抽象**

行业数据抽象是指 dex.trades、erc20.stablecoins、lending.borrow 等表。

非常重要两个表：trades，nft

**项目数据抽象**

将某个项目所需要的所有的数据汇集到一张简洁的表中。

### **社区来源表**

合作方提供（仅V2支持）

### **价格表**

通过[coinpaprika](https://coinpaprika.com/) 的API获取价格数据。

价格是基于实时市场数据的成交量加权价格，换算成美元。

![截屏2023-07-09 上午11.57.12.png](/images/ankrdunegraph/%E6%88%AA%E5%B1%8F2023-07-09_%E4%B8%8A%E5%8D%8811.57.12.png)

### 用户生成表

**请注意，这些表不能保证数据的准确性，如果不是由您自己创建，请谨慎使用。**

**请随时保存视图的构造函数参数。有时我们必须删除视图，以便能够更改某些解码表或代理依赖关系，您可能需要重新部署视图。**

## **为什么不可以用于业务开发**

1.数据虽然非常全，但表结构比较简单，大量查询需要进行数据聚合。

2.表中数据量比较大。对于业务开发可能存在大量冗余信息。

## V2版本

**问题1：**

聚合慢，索引不好创建维护

**数据库调整**

V1 面向Rows的数据库（Postgres）

![截屏2023-07-09 下午1.35.36.png](/images/ankrdunegraph/%E6%88%AA%E5%B1%8F2023-07-09_%E4%B8%8B%E5%8D%881.35.36.png)

V2面向Column的数据库（Parquet）

![截屏2023-07-09 下午1.37.54.png](/images/ankrdunegraph/%E6%88%AA%E5%B1%8F2023-07-09_%E4%B8%8B%E5%8D%881.37.54.png)

两者的对比：[https://www.youtube.com/watch?v=Vw1fCeD06YI&t=1927s](https://www.youtube.com/watch?v=Vw1fCeD06YI&t=1927s)

![截屏2023-07-09 下午1.41.48.png](/images/ankrdunegraph/%E6%88%AA%E5%B1%8F2023-07-09_%E4%B8%8B%E5%8D%881.41.48.png)

1.观察到Dune中的表格大多数是基于某几个维度数据的聚合查询。

2.Select * 这样的查询语句作用不大，大多情况是Select M(Column) 这样的聚合统计查询。所以更适合Column数据库。

3.Dune中数据的数据很少会有需要修改的情况。

4.Column数据库查询更有利于做聚合查询，更有利于做OLAP。

5.Column数据库不存在索引，避免了索引维护这一问题。

**问题2**

数据表建立问题。

**社区表**

目前接入两个数据源，作为线下数据库：

![截屏2023-07-09 下午1.52.06.png](/images/ankrdunegraph/%E6%88%AA%E5%B1%8F2023-07-09_%E4%B8%8B%E5%8D%881.52.06.png)

**数据抽象已被升级成为Spellbook**

更方便的构造表结构。

[https://dune.com/docs/zh/spellbook/how-to-guides/](https://dune.com/docs/zh/spellbook/how-to-guides/)

[https://docs.getdbt.com/docs/introduction](https://docs.getdbt.com/docs/introduction)

## 盈利模式

SaaS

![Untitled](/images/ankrdunegraph/Untitled 1.png)

## 核心

1.基于区块链生成的大量关系型数据库。

2.社区：倡导开源，鼓励优秀数据分析项目开源。上面累积了**大量优秀数据分析项目**。从而形成数据分析的生态。运营模式有些像GitHub，但用户群体的粘性会更高（数据分析项目对于Dune平台依赖性很高）。

3.不断增强社区对于平台的贡献。平台创建表 → 用户创建表。

# The Graph

## 用户群体

Dapp，数据实时性很高，查询速度一般。主要查询维度是合约。

## 基础信息

支持的网络：

[https://thegraph.com/docs/en/developing/supported-networks/](https://thegraph.com/docs/en/developing/supported-networks/)

托管：免费

自建节点：收取GRT

## GraphQL or REST

![截屏2023-07-09 下午3.14.06.png](/images/ankrdunegraph/%E6%88%AA%E5%B1%8F2023-07-09_%E4%B8%8B%E5%8D%883.14.06.png)

GraphQL 是一个用于 API 的查询语言，是一个使用基于类型系统来执行查询的服务端运行时（类型系统由你的数据定义）。

[https://graphql.cn/](https://graphql.cn/)

## 原理

**网络运行整体流程**

![截屏2023-07-10 上午12.28.36.png](/images/ankrdunegraph/%E6%88%AA%E5%B1%8F2023-07-10_%E4%B8%8A%E5%8D%8812.28.36.png)

1.A decentralized application adds data to Ethereum through a transaction on a smart contract.

2.The smart contract emits one or more events while processing the transaction.

3.Graph Node continually scans Ethereum for new blocks and the data for your subgraph they may contain.

4.Graph Node finds Ethereum events for your subgraph in these blocks and runs the mapping handlers you provided. The mapping is a WASM module that creates or updates the data entities that Graph Node stores in response to Ethereum events.

5.The decentralized application queries the Graph Node for data indexed from the blockchain, using the node's [GraphQL endpoint](https://graphql.org/learn/). The Graph Node in turn translates the GraphQL queries into queries for its underlying data store in order to fetch this data, making use of the store's indexing capabilities. The decentralized application displays this data in a rich UI for end-users, which they use to issue new transactions on Ethereum. The cycle repeats.

**网络参与者**

![截屏2023-07-11 10.07.37.png](/images/ankrdunegraph/%E6%88%AA%E5%B1%8F2023-07-11_10.07.37.png)

Developer：Create a subgraph or use existing subgraphs in a dapp.

Indexer：Operate a node to index data and serve queries.

Cursor：Organize data by signaling on subgraphs.

Delegator：Secure the network by delegating GRT to Indexers

## Subgraph

如何定义一个Subgraph：

**三个文件：**

`subgraph.yaml`: a YAML file containing the subgraph manifest

`schema.graphql`: a GraphQL schema that defines what data is stored for your subgraph, and how to query it via GraphQL

`AssemblyScript Mappings`: [AssemblyScript](https://github.com/AssemblyScript/assemblyscript) code that translates from the event data to the entities defined in your schema (e.g. `mapping.ts` in this tutorial)

`subgraph.yaml`

```jsx
specVersion: 0.0.4
description: "Subgraph for the CryptoPunks marketplace"
repository: "https://github.com/itsjerryokolo/cryptopunks"
schema:
  file: ./schema.graphql
  features:
    - grafting
  graft:
    base: QmaWuaC2x6YV8GZVNWizKtuYkyZqPGCfKMdEB15i6DYZpx
    block: 15205322
dataSources:
  - kind: ethereum/contract
    name: cryptopunks
    network: mainnet
    source:
      address: "0xb47e3cd837dDF8e4c57F05d70Ab865de6e193BBB"
      abi: cryptopunks
      startBlock: 3914494
    mapping:
      kind: ethereum/events
      apiVersion: 0.0.7
      language: wasm/assemblyscript
      entities:
        - Account
        - Punk
        - NFT
        - Transfer
        - MetaData
        - Trait
        - WrappedPunk
        - Assign
        - Offer
        - Transfer
        - Sale
      abis:
        - name: cryptopunks
          file: ./abis/cryptopunks.json
      eventHandlers:
        - event: Assign(indexed address,uint256)
          handler: handleAssign
        - event: PunkTransfer(indexed address,indexed address,uint256)
          handler: handlePunkTransfer
        - event: Transfer(indexed address,indexed address,uint256)
          handler: handleTransfer
        - event: PunkOffered(indexed uint256,uint256,indexed address)
          handler: handlePunkOffered
        - event: PunkBidEntered(indexed uint256,uint256,indexed address)
          handler: handlePunkBidEntered
        - event: PunkBidWithdrawn(indexed uint256,uint256,indexed address)
          handler: handlePunkBidWithdrawn
        - event: PunkBought(indexed uint256,uint256,indexed address,indexed address)
          handler: handlePunkBought
        - event: PunkNoLongerForSale(indexed uint256)
          handler: handlePunkNoLongerForSale
      file: ./src/mapping.ts
```

`schema.graphql`

```jsx
type Account @entity {
  "Ethereum Address"
  id: Bytes!

  "All Punks owned by Account"
  punksOwned: [Punk!] @derivedFrom(field: "owner")

  "Purchases by Account"
  bought: [Sale!]! @derivedFrom(field: "to")

  "All Punks owned by Account"
  nftsOwned: [NFT!]! @derivedFrom(field: "owner")

  "Punks assigned to account (if any)"
  assigned: [Assign!]! @derivedFrom(field: "to")

  "Punk transfers by Account"
  sent: [Transfer!]! @derivedFrom(field: "from")

  "Punk transfers to Account"
  received: [Transfer!]! @derivedFrom(field: "to")

  "Query bids by Account"
  bids: [Bid!]! @derivedFrom(field: "from")

  "Punks offered for sale by Account"
  asks: [Ask!]! @derivedFrom(field: "from")

  "Total number of Punks owned by account"
  numberOfPunksOwned: BigInt!

  "Total number of Punks assigned to account"
  numberOfPunksAssigned: BigInt!

  "Total number of transfer by Account"
  numberOfTransfers: BigInt!

  "Total number of sales by Account"
  numberOfSales: BigInt!

  "Total number of purchases by Account"
  numberOfPurchases: BigInt!

  "Total amount spent buying Punks by Account"
  totalSpent: BigInt!

  "Total amount earned by Account from selling Punks"
  totalEarned: BigInt!

  "Average amount spent buying Punks by Account"
  averageAmountSpent: BigInt!

  "Account URL"
  accountUrl: String!
}
```

`mapping.ts`

```jsx
export function handleTransfer(event: cTokenTransfer): void {
  /**
     @summary cToken as helper entity
          e.g: https://etherscan.io/tx/0x23d6e24628dabf4fa92fa93630e5fa6f679fac75071aab38d7e307a3c0f4a3ca#eventlog
   */
  if (event.params.to.toHexString() != ZERO_ADDRESS) {
    let fromAccount = getOrCreateAccount(event.params.from)
    let toAccount = getOrCreateAccount(event.params.to)
    let cToken = getOrCreateCToken(event)

    cToken.from = event.params.from
    cToken.to = event.params.to
    cToken.owner = event.params.to.toHexString()
    cToken.amount = event.params.value

    //Write
    cToken.save()
    toAccount.save()
    fromAccount.save()
  }
}

export function getOrCreateAccount(address: Address): Account {
  let id = address as Bytes
  let account = Account.load(id)
  let url = 'https://cryptopunks.app/cryptopunks/accountinfo?account='

  if (!account) {
    account = new Account(id)
    account.numberOfPunksOwned = BIGINT_ZERO
    account.numberOfSales = BIGINT_ZERO
    account.totalEarned = BIGINT_ZERO
    account.numberOfTransfers = BIGINT_ZERO
    account.numberOfPunksAssigned = BIGINT_ZERO
    account.numberOfPurchases = BIGINT_ZERO
    account.totalSpent = BIGINT_ZERO
    account.averageAmountSpent = BIGINT_ZERO
    account.accountUrl = url.concat(id.toHexString())

    account.save()
  }

  return account as Account
}

export function getOrCreateCToken(event: ethereum.Event): CToken {
  let cToken = CToken.load(getGlobalId(event))
  if (!cToken) {
    cToken = new CToken(getGlobalId(event))
    cToken.referenceId = cToken.id
    cToken.blockNumber = event.block.number
    cToken.blockHash = event.block.hash
    cToken.txHash = event.transaction.hash
    cToken.timestamp = event.block.timestamp
  }
  return cToken as CToken
}
```

如何创建子图：

[https://thegraph.com/docs/en/developing/creating-a-subgraph/](https://thegraph.com/docs/en/developing/creating-a-subgraph/)

完整项目地址：

[https://github.com/itsjerryokolo/CryptoPunks](https://github.com/itsjerryokolo/CryptoPunks)

子图市场

![Untitled](/images/ankrdunegraph/Untitled 2.png)

![Untitled](/images/ankrdunegraph/Untitled 3.png)

## 应用

Dodo：

[https://app.dodoex.io/pool?network=mainnet](https://app.dodoex.io/pool?network=mainnet)

Uniswap:

[https://info.uniswap.org/#/](https://info.uniswap.org/#/)

## 经济模型

![截屏2023-07-11 10.16.19.png](/images/ankrdunegraph/%E6%88%AA%E5%B1%8F2023-07-11_10.16.19.png)

看一下Indexer的主要收入来源：

![截屏2023-07-13 上午1.01.54.png](/images/ankrdunegraph/%E6%88%AA%E5%B1%8F2023-07-13_%E4%B8%8A%E5%8D%881.01.54.png)

可以发现，查询获得的GRT是非常少的。大体上主要收入还是来自Stake 和 Indexing。消费者太少了。感觉并不是一个很健康的状态，是否会导致GRT通胀？

### （纯个人观点）

APP

Web2 后端主要作用是：数据，数据操作（增删改查）。

DAPP

Web3重要数据都存储在链上，且不可以修改删除，数据提交可以直接通过RPC调用。

理论上如果可以解决查询的问题，前端可以不再依赖后端。

需求 → 后端根据数据库结构定义接口 → 前端开发

需求 → 前端根据子图使用GraphQL直接查询数据

但是感觉The Graph的经济系统有些危险。GRT的消费场景主要是查询，但是目前消费量感觉很少。其他方向的生态也没有发展（相比于Ankr）。

目前主要用户应该就是Dapp。其他信息整合的工具应用一般不会使用The Graph（因为查询性能不高，工具类产品查询内容更偏向标准化的信息）。

总体看他是一个很有技术创新的产品。但这个想做的模式能不能成功还有待观察。

查询总量对比：

The Graph   540M 每月（付费查询次数）287节点

Quick Node 200B 每月（总次数） 每月

数据是公开的，如何建立壁垒？

1.在原始数据之上进行数据处理，私有化上层数据/数据处理方式。

2.做协议。形成行业共识，代币经济学。（App Chain，Bridge，GameFi, Defi…）

## 对比


|  | 查询速度 | 查询实时性 | 数据特征 | 使用场景 | 生态 | 案例 |
| --- | --- | --- | --- | --- | --- | --- |
| Ankr | 快 | 高 | 固定接口，导致只可以做较为通用数据的简单查询。 | 要求返回速率较快的接口。 | 代币经济学 | Quicknode<br>avax<br>Polygon |
| Dune | 慢 | 低 | 表固定，通用数据的复杂查询 | 数据分析 | 类似GitHub开源社区 |  |
| The Graph | 一般 | 高 | 适合定制化，特定Dapp的复杂数据查询 | 为复杂Dapp提供类似后端接口的功能。 | 代币经济学 | [Uniswap](https://info.uniswap.org/#/) |