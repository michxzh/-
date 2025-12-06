# clientDemo — iOS 消息中心 Demo（含数据分析与增长策略）

## 📌 目录
	•	项目简介￼
	•	功能列表￼
	•	技术方案￼
	•	系统架构￼
	•	核心难点与解决方案￼
	•	运行环境￼
	•	安装与运行指南￼
	•	项目结构￼
	•	截图展示￼
	•	后续计划￼

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



## 进阶功能（Advanced Features）

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

## 自由探索功能（Growth & Analytics）

### 消息召回 & 增长策略分析（增长体系 Demo）

	•	每日新增消息统计
	•	未读数趋势（折线图）
	•	消息打开率（CTR）
	•	消息类型 CTR（系统消息 / 图片消息 / 运营消息）
	•	在个人页或备注页展示数据看板（Charts）

