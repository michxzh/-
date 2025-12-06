# clientDemo — iOS 消息中心 Demo（含数据分析与增长策略）

## 📌 目录
	•	项目简介￼
	•	功能列表￼
	•	技术方案￼
	•	核心难点与解决方案￼
	•	运行环境￼
	•	安装与运行指南￼
	•	项目结构￼
	•	截图展示￼

## 项目简介
本项目是一个使用 SwiftUI + SQLite + MVVM 架构 实现的完整消息中心 Demo，功能覆盖消息流展示、持久化、备注编辑、实时消息模拟、搜索、高级时间文案、弱网体验、Schema Migration、以及埋点与增长策略分析。

工程结构清晰、模块化拆分合理，包含：

	•	UI 层（SwiftUI）：消息列表、消息 Cell、备注页、数据看板、骨架屏、错误态等
	•	ViewModel 层（MVVM）：分页、搜索、排序、交互逻辑、Mock 消息中心
	•	数据层（Repository + JSON + SQLite）：本地 JSON 数据源、状态持久化、多表 Schema 管理
	•	服务层（Analytics / Message Center）：埋点系统、CTR 计算、趋势分析、自动消息推送模块

## 功能列表

### 工程环境与架构

	•	使用 Swift + SwiftUI（原生）
	•	采用 MVVM + Repository + Persistence Layer
	•	完整模块化：UI / ViewModel / Repository / Persistence / Analytics
	•	SQLite3 原生数据库接入 + Migration 模块
	•	良好的可维护性：命名规范、分层清晰、独立网络与存储模块


### 消息列表页（仿抖音消息首页）

✔ UI 功能

	•	混排好友消息 + 系统消息
	•	消息 Cell 包含：头像、昵称、时间文案、消息摘要、未读角标
	•	自动布局支持高度变化

✔ 交互能力

	•	下拉刷新（refreshable）
	•	上滑加载更多（分页加载）
	•	空态页面（无数据 / 首次失败）
	•	重试按钮
	•	骨架屏（Skeleton Loading UI）

### 数据要求

	•	本地 JSON 作为模拟数据源
	•	首次进入加载 ≥ 20 条
	•	分页加载（模拟服务端分页）


### 备注页（Message Remark Page）

	•	点击消息进入备注详情页
	•	支持编辑备注文本
	•	保存内容持久化入 SQLite
	•	返回后主列表实时展示备注
	•	SQLite 可使用 sqlite3 / FMDB / GRDB（此项目用 sqlite3）
	•	备注页面包含转场动画（渐变 + 卡片放大）



### 本地持久化（Local Persistence）

	•	消息未读状态持久化
	•	本地备注存储
	•	用户交互（置顶等）完整落地 SQLite
	•	支持冷启动同步状态
	•	Schema Migration：自动新增字段 isPinned



### 进阶功能（Advanced Features）

### 本地消息中心模拟（Local Message Center）

	•	定时器模拟服务器推送（每 5 秒插入新消息）
	•	新消息到达后：列表实时刷新
	•	自动滚动到顶部
	•	未读数 +1
	•	触发埋点统计

### 消息的类型化展示

	•	纯文本： 普通系统消息
	•	图片消息： 自动拉伸高度显示图片
	•	运营类消息： 显示「领取奖励」等按钮，可点击
	•	Cell 支持动态高度撑高

### 消息时间文案（抖音同款规则）

	•	1 分钟内：刚刚
	•	1 小时内：xx 分钟前
	•	今天：HH:mm
	•	昨天：昨天 HH:mm
	•	7 天内：x 天前
	•	超过 7 天：MM-dd
	
### 搜索能力（Search）

	•	可搜索昵称 + 消息摘要
	•	搜索词高亮展示
	•	与正常消息 UI 完全复用
	•	空搜索时显示全部列表



### 自定义转场动画（Custom Transition）

	•	渐变动画
	•	卡片跟手放大效果（matchedGeometryEffect）
	•	下滑关闭手势（drag to dismiss）

### SQLite Schema Migration

	•	自动检测字段是否存在（PRAGMA table_info）
	•	自动新增 isPinned 字段
	•	保证旧版本用户不崩溃
	•	数据表自动初始化



### 弱网 / 无网体验

	•	首刷超时（5 秒）自动进入错误态
	•	错误页 + 重试按钮
	•	加载中使用 Skeleton 占位
	•	模拟服务端延迟 / 网络错误

### 自由探索功能（Growth & Analytics）

### 消息召回 & 增长策略分析（增长体系 Demo）

	•	每日新增消息统计
	•	未读数趋势（折线图）
	•	消息打开率（CTR）
	•	消息类型 CTR（系统消息 / 图片消息 / 运营消息）
	•	在个人页或备注页展示数据看板（Charts）
	
## 技术方案
本项目采用 SwiftUI + MVVM 架构，数据层使用 SQLite 持久化。

	•	SwiftUI：构建 UI 更高效，动画与列表能力强，便于实现 Cell 自动布局与转场效果。
	•	MVVM：将 UI 与业务逻辑解耦，提高模块化、可维护性、可测试性。
	•	Repository：数据源可替换（本地 JSON → 网络接口 → SQLite）。
	•	SQLite：轻量但可靠，适用于未读数、备注、消息状态等持久化场景。
	•	单例服务（AnalyticsManager / MessageCenter）：统一管理埋点与消息推送模拟，降低依赖

## 核心难点与解决方案

### 消息分页 + 本地状态（未读 / 备注 / 置顶）合并

       - 难点：JSON 是静态数据，但未读、备注、置顶需要动态更新并持久化。
       - 解决方案：
	   
           • 使用 Repository 合并 JSON + SQLite 数据
           • 冷启动读取 SQLite 状态覆盖原始消息
           • 统一排序规则（置顶优先 → 时间倒序）

### Message Cell 动态高度（文本 / 图片 / 按钮 三种体裁）

       - 难点：每种消息显示方式不同，Cell 需要自动撑开。
       - 解决方案：
	   
           • SwiftUI VStack + switch 动态渲染内容
           • 自动适配高度，与 List 完全兼容

### 时间文案规则实现（刚刚 / x 分钟前 / 昨天 / 7 天内 / MM-dd）

       - 难点：多规则判断且需本地化。
       - 解决方案：
	   
           • 使用 Calendar + DateComponents 计算差值
           • 封装 TimeFormatter.shared.format()

### 模拟实时消息中心（每 5 秒推送一次）

       - 难点：推送消息需同步刷新 UI、未读、动画滚动。
       - 解决方案：
	   
           • 独立 MessageCenter（Timer 模拟推送）
           • 插入消息自动触发 UI 刷新 + 滚动到顶部
           • 同时记录埋点（new_message）

### SQLite Schema Migration（新增 isPinned 字段）

       - 难点：确保老版本数据库不崩溃。
       - 解决方案：
	   
           • 使用 PRAGMA table_info 检查字段
           • 缺少时自动执行 ALTER TABLE
           • 保证迁移过程幂等、安全

### 弱网/无网状态处理（错误态 / 重试 / Skeleton 骨架屏）

       - 难点：本地数据无法模拟真实网络加载。
       - 解决方案：
	   
           • 加载前添加超时检测（5s）
           • isLoading / isError / isEmpty 多状态切换
           • SkeletonListView 提升体验

### 数据埋点链路（CTR、趋势分析、数据可视化）

       - 难点：分析逻辑必须可追踪、可统计。
       - 解决方案：
	   
           • 设计 analytics_event 表存储行为
           • AnalyticsManager 统一埋点写入
           • SQL 分析 CTR、趋势
           • Swift Charts 可视化呈现

## 运行环境

    • macOS 14+
    • Xcode 15+
    • Swift 5.9+
    • iOS 17 模拟器或真机
    • 无需后端服务（使用 JSON + SQLite 本地数据）
	
## 安装与运行指南

    1. 克隆项目
	
       git clone https://github.com/michxzh/clientDemo.git
       cd clientDemo

    2. 打开工程
	
       打开文件：通过xcode打开clientDemo

    3. 安装依赖
	
       • 本项目无第三方库依赖（纯原生 SwiftUI + SQLite）
       • 直接运行即可

    4. 运行项目
	
       • 选择任意 iPhone 模拟器
       • 点击 Xcode ▶ Run

    5. （可选）重置数据库
	
       方式 1：删除沙盒 Documents/messages.sqlite
       方式 2：删除模拟器 App 重新安装
