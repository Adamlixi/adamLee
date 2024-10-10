---
layout: post
tags: [onchain-game]
title: "Sky Strife分析"
---


### 游戏简介

[https://www.youtube.com/watch?v=5tcVxDrxKag](https://www.youtube.com/watch?v=5tcVxDrxKag)

### 游戏总系统总览

**数据相关**

- **analytics：监听游戏发出的 Event，并整理成 CSV 存储在本地**
    
    ![截屏2024-01-25 下午10.18.39.png](/images/%E6%88%AA%E5%B1%8F2024-01-25_%E4%B8%8B%E5%8D%8810.18.39.png)
    
- **analytics-worker：cloudflare的一个客户端，可以直接发数据发送存储在cloudflare D1 中**

**前端相关**

- client: 客户端，调用底层游戏引擎，发送交易，包装美术资源。
- phaserx: 前端使用的游戏引擎（魔改[phaser](https://phaser.io/tutorials/making-your-first-phaser-3-game-chinese)）
- ecs-brower: 前端 Debug 可视化工具
    
    ![截屏2024-01-25 下午10.14.09.png](/images/%E6%88%AA%E5%B1%8F2024-01-25_%E4%B8%8B%E5%8D%8810.14.09.png)
    
- art: 美术资源

**合约相关**

- contracts：合约核心逻辑，基于MUD引擎。
    
    ![截屏2024-01-23 下午2.14.16.png](/images/%E6%88%AA%E5%B1%8F2024-01-23_%E4%B8%8B%E5%8D%882.14.16.png)
    
- bots：数据修改机器人。目前主要上传地图，实例化地图，创建 Debug 测试地图。

运行：

[https://arc.net/folder/CCCC2B0F-DA7D-435B-96C9-ED66E72B0CCD](https://arc.net/folder/CCCC2B0F-DA7D-435B-96C9-ED66E72B0CCD)

### 游戏数值相关

**Map 配置**

无需改代码

在 map 文件下，通过 level Id 进行配置。

2/3/4 对局各两个地图

[map 配置](https://www.notion.so/map-1-11ba8529676f8024bfbcd4566a2abee3?pvs=21)

| 设置 | 机制说明 | 位置 | 默认值 | 是否可配 |
| --- | --- | --- | --- | --- |
| 移动CD值 | 上次执行时间之后 需要等待 | block(MatchSystem 硬编码)
turnLength: 15  | 15 s | 非配置，需改合约 |
| Cost Create Match | 创建房间的成本 | Deploy 硬编码 | 100 | 非配置，需改部署合约 |
| *FULL_READY_START_WAIT* | 开始时间倒数（玩家都 Ready） | LibMatch 硬编码 | 5 s | 非配置，需改部署合约 |
| *FORCE_START_WAIT* | 强制开始时间（有人没有 Ready） | LibMatch 硬编码 | 2 min | 非配置，需改部署合约 |
| Gold 结算 | 每轮获取Gold 的时间 | 硬编码 | 15 s | 非配置，需改部署合约 |

**游戏基础数值配置**

**Template 设置**

游戏基础数值设置，通过 template Id 来配置。游戏中的 Entity 是对template的实例化。

[template 设置](https://www.notion.so/template-1-11ba8529676f80919a7cdea1fc6ddcae?pvs=21)

**Advanced unit stats**

### 代币经济学相关

**每局奖励**`🔮`

![截屏2024-01-26 下午2.23.22.png](/images/%E6%88%AA%E5%B1%8F2024-01-26_%E4%B8%8B%E5%8D%882.23.22.png)

```solidity
uint256 constant COST_CREATE_MATCH = 100 ether; // Deploy 部署设置

// Match reward multiplier is inversely proportional to
// the `numberOfMatches` that took place in the previous X blocks.
function getReward(uint256 numberOfMatches) view returns (uint256) {
  uint256 cost = SkyPoolConfig.getCost();
  if (numberOfMatches < 100) {
    return 5 * cost;
  } else if (numberOfMatches < 200) {
    return 4 * cost;
  } else if (numberOfMatches < 300) {
    return 3 * cost;
  } else if (numberOfMatches < 400) {
    return 2 * cost;
  } else if (numberOfMatches < 500) {
    return cost;
  } else if (numberOfMatches < 600) {
    return (4 * cost) / 5;
  } else if (numberOfMatches < 700) {
    return (3 * cost) / 5;
  } else if (numberOfMatches < 800) {
    return (2 * cost) / 5;
  } else if (numberOfMatches < 900) {
    return (1 * cost) / 5;
  } else if (numberOfMatches < 10000) {
    return (1 * cost) / 10;
  }
```

**奖励分配**`🔮`

![截屏2024-01-26 下午2.23.50.png](/images/%E6%88%AA%E5%B1%8F2024-01-26_%E4%B8%8B%E5%8D%882.23.50.png)

Deploy 硬编码：

```solidity
uint256[] memory fourPlayerPercentages = new uint256[](4);
fourPlayerPercentages[0] = 60;
fourPlayerPercentages[1] = 30;
fourPlayerPercentages[2] = 10;
fourPlayerPercentages[3] = 0;
MatchRewardPercentages.set(4, fourPlayerPercentages);

uint256[] memory threePlayerPercentages = new uint256[](3);
threePlayerPercentages[0] = 70;
threePlayerPercentages[1] = 30;
threePlayerPercentages[2] = 0;
MatchRewardPercentages.set(3, threePlayerPercentages);

uint256[] memory twoPlayerPercentages = new uint256[](2);
twoPlayerPercentages[0] = 100;
twoPlayerPercentages[1] = 0;
MatchRewardPercentages.set(2, twoPlayerPercentages);
```

**Season Pass ERC721**`🎫`

![截屏2024-01-26 下午2.24.12.png](/images/%E6%88%AA%E5%B1%8F2024-01-26_%E4%B8%8B%E5%8D%882.24.12.png)

season pass 目前主要作用有三个:

- 允许玩家创建比赛房间。
- 可以自由选择地图。
- 可以选择英雄。

its minted at the beginning of a season and increases in price every time someone buys it. 

Start Price：0.005 ETH

MIN  Price:   0.001 ETH

Season Price 动态变化：

动态调节币价的机制：

如果购买频繁，币价会上升。

没有购买，币价会逐渐下降。

```solidity
// The price lazily decreases based on how much time has passed.
// eg. if the starting price is 1000, and 50 seconds have passed, the actual price is now 950.
function calculateCurrentPrice() view returns (uint256 price) {
  uint256 startingPrice = SeasonPassConfig.getStartingPrice();
  uint256 minPrice = SeasonPassConfig.getMinPrice();
  uint256 rate = SeasonPassConfig.getRate();

  uint256 lastSaleAt = SeasonPassLastSaleAt.get();
  // This cannot overflow because block.timestamp is always ahead of last sale
  uint256 timeSinceLastSale = block.timestamp - lastSaleAt;
  uint256 difference = ((startingPrice * rate) / SEASON_PASS_PRICE_DECREASE_DENOMINATOR) * timeSinceLastSale;

  // Avoid integer underflow
  if (startingPrice > difference) {
    price = startingPrice - difference;
    // Price cannot go below minimum price
    if (price < minPrice) {
      price = minPrice;
    }
  } else {
    price = minPrice;
  }
}

function buySeasonPass(address account) public payable {
    require(!hasSeasonPass(account), "this account already has a season pass");
    require(block.timestamp < SeasonPassConfig.getMintCutoff(), "season pass minting has ended");

    uint256 price = calculateCurrentPrice();
    require(_msgValue() >= price, "you must pay enough");

    uint256 tokenId = SeasonPassIndex.get();
    require(tokenId < MAX_TOKEN_ID, "all season passes have been minted");

    // Mint season pass
    IERC721Mintable token = IERC721Mintable(SkyPoolConfig.getSeasonPassToken());
    token.mint(account, tokenId);

    // Update auction data
    SeasonPassIndex.set(tokenId + 1);
    SeasonPassLastSaleAt.set(block.timestamp);

    uint256 multiplier = SeasonPassConfig.getMultiplier();
    uint256 newStartingPrice = (price * multiplier) / DENOMINATOR;
    SeasonPassConfig.setStartingPrice(newStartingPrice);

    uint256 refundAmount = _msgValue() - price;
    if (refundAmount > 0) {
      (bool sent, bytes memory data) = _msgSender().call{ value: refundAmount }("");
      require(sent, "failed to send refund");
    }
  }
```

**ERC721 SkyKey**

团队测试使用的NFT，可以不扣除费用创建房间。

From Discord：

Sky Key is an NFT that allows the holder to change Sky Strife. that's what we use to modify the game.

Also it allows the holder to create matches without paying the normal creation cost

eventually we lock the MUD world and the only way to modify anything will be through the Sky Key i.e. contracts become non-upgradeable

### 游戏核心系统相关

如何攻击：

每次攻击都需要等15s的体力值恢复。

```solidity
function fight(bytes32 matchEntity, bytes32 entity, bytes32 target) public {
    _act(matchEntity, entity);

    _attack(matchEntity, entity, target);
  }

function _act(bytes32 matchEntity, bytes32 entity) internal {
    require(matchHasStarted(matchEntity), "match has not started");
    require(isOwnedBy(matchEntity, entity, addressToEntity(_msgSender())), "you do not own this unit");

    uint256 lastActionAt = LastAction.get(matchEntity, entity);
    require(
      LibStamina.getCurrentTurn(matchEntity) > LibStamina.getTurnAt(matchEntity, lastActionAt),
      "not enough time has passed since last action"
    );

    LastAction.set(matchEntity, entity, block.timestamp);
  }

function _attack(bytes32 matchEntity, bytes32 entity, bytes32 target) internal {
    require(getOwningPlayer(matchEntity, entity) != getOwningPlayer(matchEntity, target), "cannot attack own entity");
    require(Combat.getStrength(matchEntity, entity) > 0, "attacker has no strength");
    require(Combat.getHealth(matchEntity, target) > 0, "defender has no health");

    RangeData memory range = Range.get(matchEntity, entity);
    int32 distanceToTarget = manhattan(Position.get(matchEntity, entity), Position.get(matchEntity, target));
    require(distanceToTarget >= range.min, "target is below minimum range");
    require(distanceToTarget <= range.max, "target is above maximum range");

    SystemSwitch.call(abi.encodeCall(AttackSystem.attack, (matchEntity, entity, target)));
  }
```

攻击分为两步：

_act:判定攻击是否合法。

_attack:进行攻击。

攻击系统细节：

```solidity
function attack(bytes32 matchEntity, bytes32 attacker, bytes32 defender) public {
    int32 attackerDamage = LibCombat.calculateDamageAttacker(matchEntity, attacker, defender);
    int32 defenderDamage = LibCombat.calculateDamageDefender(matchEntity, attacker, defender);

    (bool defenderDied, bool defenderCaptured) = LibCombat.dealDamage(matchEntity, attacker, defender, attackerDamage);

    bool attackerDied;
    bool ranged = Range.getMax(matchEntity, attacker) != 1;
    // If the attacker is in melee range and the defender is not passive,
    // the defender counterattacks
    if (!ranged && !LibCombat.isPassive(matchEntity, defender)) {
      (attackerDied, ) = LibCombat.dealDamage(matchEntity, defender, attacker, defenderDamage);
    }

    // trigger kills after combat is evaluated
    // if we trigger them before, units may be dead and we can't access their data
    if (defenderDied) LibCombat.kill(matchEntity, defender);
    if (attackerDied) LibCombat.kill(matchEntity, attacker);

    SystemSwitch.call(
      abi.encodeCall(
        CombatResultSystem.setCombatResult,
        (
          matchEntity,
          attacker,
          CombatResultData({
            attacker: attacker,
            defender: defender,
            attackerDamageReceived: defenderDamage,
            defenderDamageReceived: attackerDamage,
            attackerDamage: attackerDamage,
            defenderDamage: defenderDamage,
            ranged: ranged,
            attackerDied: attackerDied,
            defenderDied: defenderDied,
            defenderCaptured: defenderCaptured
          })
        )
      )
    );
  }
```

进攻系统数值判定

[数值 (1)](https://www.notion.so/1-11ba8529676f80389af4d671b1c923c0?pvs=21)

移动系统：

```solidity
function move(bytes32 matchEntity, bytes32 entity, PositionData[] memory path) public {
    _act(matchEntity, entity);

    _move(matchEntity, entity, path);
  }

function _act(bytes32 matchEntity, bytes32 entity) internal {
    require(matchHasStarted(matchEntity), "match has not started");
    require(isOwnedBy(matchEntity, entity, addressToEntity(_msgSender())), "you do not own this unit");

    uint256 lastActionAt = LastAction.get(matchEntity, entity);
    require(
      LibStamina.getCurrentTurn(matchEntity) > LibStamina.getTurnAt(matchEntity, lastActionAt),
      "not enough time has passed since last action"
    );

    LastAction.set(matchEntity, entity, block.timestamp);
  }

function _move(bytes32 matchEntity, bytes32 entity, PositionData[] memory path) internal {
    bytes32 player = addressToEntity(_msgSender());

    bytes32 levelId = MatchConfig.getLevelId(matchEntity);

    int32 moveSpeed = Movable.get(matchEntity, entity);
    PositionData memory position = Position.get(matchEntity, entity);
    int32 requiredMovement = LibMove.calculateUsedMoveSpeed(matchEntity, levelId, player, position, path);
    require(moveSpeed >= requiredMovement, "not enough move speed");

    setPosition(matchEntity, entity, path[path.length - 1]);
  }
```

_act:判定移动是否合法。

_move: 进行移动.

Move and attack:

移动加攻击可以节省一次体力消耗

```solidity
function moveAndAttack(bytes32 matchEntity, bytes32 entity, PositionData[] memory path, bytes32 target) public {
    _act(matchEntity, entity);

    _move(matchEntity, entity, path);
    _attack(matchEntity, entity, target);
  }
```

### 游戏内经济系统

黄金生成：

![截屏2024-01-26 下午2.24.47.png](/images/%25E6%2588%25AA%25E5%25B1%258F2024-01-26_%25E4%25B8%258B%25E5%258D%25882.24.47.png)

15s黄金提取一次

```solidity
function getChargerStaminaRegen(bytes32 matchEntity, bytes32 chargee) internal returns (int32 extraStamina) {
    bytes32[] memory chargers = Chargers.get(matchEntity, chargee);

    int32 currentTurn = getCurrentTurn(matchEntity);
    int32 turnsSinceLastAction = currentTurn - getTurnAt(matchEntity, LastAction.get(matchEntity, chargee));

    for (uint256 i; i < chargers.length; i++) {
      bytes32 chargeOrigin = chargers[i];

      int32 chargerStamina;
      {
        uint256 startedAt = ChargedByStart.get(matchEntity, chargeOrigin);

        int32 extraStaminaTurns = startedAt > LastAction.get(matchEntity, chargee)
          ? currentTurn - getTurnAt(matchEntity, startedAt)
          : turnsSinceLastAction;

        chargerStamina = extraStaminaTurns * Charger.get(matchEntity, chargeOrigin);
      }

      if (ChargeCap.getCap(matchEntity, chargeOrigin) > 0) {
        chargerStamina = capChargerStamina(matchEntity, chargeOrigin, chargerStamina);
      }

      extraStamina += chargerStamina;
    }

    return extraStamina;
  }
```

### 游戏钱包相关

![截屏2024-01-26 下午2.25.15.png](/images/%E6%88%AA%E5%B1%8F2024-01-26_%E4%B8%8B%E5%8D%882.25.15.png)

**Session wallets**. Normally a wallet requires the user to authorize each transaction separately. In the case of a blockchain game, this means having to authorize every move, which is excessive. Using account delegation players can authorize a different wallet, one whose private key is stored on the client, to act on their behalf. Because this wallet's private key is stored in the client, rather than a browser extension, the client can decide when asking for authorization is warranted and when it isn't. By making sure this is a *separate* wallet, we protect the player's main account in the case of vulnerable or malicious game clients.

目前 SS 使用 **Session wallets**

生成一个 EOA 钱包，之后把部分 ETH 转入。之后所有操作前端直接签署。
