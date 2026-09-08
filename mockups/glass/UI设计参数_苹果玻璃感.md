# UI 设计参数 · 苹果玻璃磨砂（Liquid Glass）

> **Claude Design 规范源：** 仓库根目录 [`DESIGN.md`](../../DESIGN.md)（Google Stitch / Claude Design 可上传格式）。  
> 本文是中文展开说明；Token 以 `DESIGN.md` YAML front matter 为准。  
> 视觉参考：同目录 `p1-*-glass.png`；由 DESIGN.md 再生图见 `from-design-md/`。  
> 技术栈：Flutter（Android 先发）；视觉语言对齐 iOS 玻璃感，但保留 Android 状态栏/系统导航。

---

## 1. 设计原则（写代码时优先遵守）

1. **玻璃优先**：可交互容器默认是半透明 + 背景模糊，不是实色卡片。
2. **暖色陪伴**：保留孕期暖桃/玫瑰/奶油；禁止紫系霓虹、默认暗黑、强发光。
3. **一层一职**：背景氛围层 / 玻璃内容层 / 悬浮导航层 分离；不要把所有东西糊成同一不透明度。
4. **动效服务层级**：动画表达「浮起、弹簧、模糊切换」，不做花哨粒子。
5. **信息架构不变**：屏幕结构、中文文案、角色锁定逻辑与原版 mockup 一致，只升级材质与动效。

---

## 2. 色板（Color Tokens）

### 2.1 品牌与文字

| Token | Hex / 值 | 用途 |
|---|---|---|
| `color.brand.peach` | `#F5D5C8` | 暖桃主氛围、选中 tint |
| `color.brand.rose` | `#E8A598` | 主按钮、用户气泡、强调 |
| `color.brand.roseDeep` | `#C97B6E` | 按下态、链接强调 |
| `color.brand.cream` | `#F7F1EA` | 页面底色起点 |
| `color.brand.blush` | `#F3E4DC` | 渐变中段 |
| `color.text.primary` | `#4A3728` | 主标题、正文 |
| `color.text.secondary` | `#8A7A6C` | 副标题、元数据、来源 |
| `color.text.onAccent` | `#FFFFFF` | 玫瑰按钮/用户气泡上的字 |
| `color.status.online` | `#5BB98A` | 「在线」点/字 |
| `color.locked.icon` | `#B5A89C` | 锁定角色图标 |
| `color.divider` | `rgba(74,55,40,0.08)` | 列表分割线 |

### 2.2 玻璃填充（Glass Fills）

| Token | 值 | 用途 |
|---|---|---|
| `glass.fill.light` | `rgba(255,255,255,0.55)` | 默认卡片、设置列表、助手气泡 |
| `glass.fill.medium` | `rgba(255,255,255,0.40)` | 英雄卡、底栏、输入条 |
| `glass.fill.heavy` | `rgba(255,255,255,0.72)` | 弹窗 Sheet、需更高可读性区域 |
| `glass.fill.rose` | `rgba(232,165,152,0.45)` | 激活角色卡（小暖）、选中 tab pill |
| `glass.fill.roseSoft` | `rgba(245,213,200,0.35)` | 信息 Banner、睡眠卡 tint |
| `glass.fill.locked` | `rgba(255,255,255,0.32)` | 锁定卡片（更冷、更透） |
| `glass.stroke` | `rgba(255,255,255,0.65)` | 玻璃描边（高光边） |
| `glass.stroke.soft` | `rgba(255,255,255,0.35)` | 弱边线 |
| `scrim.modal` | `rgba(74,55,40,0.28)` | 弹窗背后遮罩 |

### 2.3 背景氛围（Atmosphere）

页面**不要**用纯实色 `#F7F1EA`。使用纵向渐变 + 柔光斑：

```
background.gradient:
  top    → color.brand.cream   (#F7F1EA)
  mid    → color.brand.blush   (#F3E4DC)
  bottom → #EBD5CB（略深桃）

background.orbs（装饰，非交互）:
  - 右上：半径 ~180dp，色 #F5D5C8 @ 0.45，blur 80
  - 左下：半径 ~140dp，色 #E8A598 @ 0.25，blur 60
```

Flutter 实现提示：底层 `Container` 渐变 + 1～2 个 `ImageFiltered`/`BackdropFilter` 不可用时用低透明度 `Circle` 模糊近似；玻璃层再用 `BackdropFilter(blur)`。

---

## 3. 材质（Material / Glass）

### 3.1 标准玻璃组件参数

| 属性 | Token | 值 |
|---|---|---|
| 背景模糊 | `glass.blur` | `sigmaX/Y = 24`（弹窗可用 `32`） |
| 填充 | 见 §2.2 | 按组件选 light / medium / heavy |
| 描边 | `glass.borderWidth` | `1.0` logical px |
| 描边色 | `glass.stroke` | 见上 |
| 圆角 · 大卡 | `radius.xl` | `24` |
| 圆角 · 中卡 | `radius.lg` | `20` |
| 圆角 · 小控件 | `radius.md` | `14` |
| 圆角 · 胶囊 | `radius.pill` | `999`（输入条、底栏、chip） |
| 圆角 · Sheet | `radius.sheet` | `28` |

### 3.2 阴影（多层弥散，非 Material 默认 elevation）

| Token | 值 | 用途 |
|---|---|---|
| `shadow.card` | `0 8 24 rgba(74,55,40,0.10)` + `0 2 6 rgba(74,55,40,0.06)` | 普通玻璃卡 |
| `shadow.float` | `0 12 32 rgba(74,55,40,0.14)` + `0 4 8 rgba(74,55,40,0.08)` | 底栏、输入条、英雄卡 |
| `shadow.sheet` | `0 24 48 rgba(74,55,40,0.18)` | 隐私弹窗等 Sheet |
| `shadow.glow.rose` | `0 0 20 rgba(232,165,152,0.35)` | 激活态轻光晕（克制） |

禁止：多层彩色霓虹 glow、过重黑色投影。

---

## 4. 字体与间距

### 4.1 字体

| Token | 建议 | 字重 | 用途 |
|---|---|---|---|
| `type.display` | PingFang SC / SF Pro 中文替代 | Semibold 600 | 「孕16周」等英雄标题 ~28–32sp |
| `type.title` | 同上 | Semibold 600 | 页标题、区块标题 ~18–20sp |
| `type.body` | 同上 | Regular 400 | 正文、气泡 ~15–16sp |
| `type.caption` | 同上 | Regular 400 | 来源、元数据 ~12–13sp |
| `type.label` | 同上 | Medium 500 | Tab、按钮、状态 ~12–14sp |

行高：正文 `1.45`；标题 `1.25`。字色用 §2.1，不用纯黑。

### 4.2 间距（Spacing）

| Token | 值 |
|---|---|
| `space.xs` | `4` |
| `space.sm` | `8` |
| `space.md` | `12` |
| `space.lg` | `16` |
| `space.xl` | `24` |
| `space.xxl` | `32` |
| `page.paddingH` | `16`～`20` |
| `section.gap` | `20`～`24` |
| `nav.bottomClearance` | 底栏高度 + `16`（内容避开悬浮底栏） |

---

## 5. 组件规格

### 5.1 顶栏（App Bar）

- 材质：`glass.fill.medium` + `glass.blur` + 底部分割发丝线 `glass.stroke.soft`
- 高度：状态栏之下 `56`
- 标题：`type.title` + `color.text.primary`，居中
- 图标：线宽 ~1.5，色 `color.text.primary`，风格接近 SF Symbols

### 5.2 悬浮底栏（Tab Bar）

- 形态：**悬浮胶囊**，左右 margin `16`，底 margin `含安全区 + 8`
- 材质：`glass.fill.medium` + `shadow.float` + `radius.pill`
- 三项：首页 / 对话 / 我的
- 选中：`glass.fill.rose` 小 pill 包裹图标+文案，可加 `shadow.glow.rose`（很弱）
- 未选中：线框图标 + `color.text.secondary`
- **不要**用粗下划线作为主选中指示（原版可弃）

### 5.3 英雄卡（孕周）

- 材质：`glass.fill.medium` + 轻微 peach 内渐变 + `shadow.float`
- 圆角：`radius.xl`
- 左侧：chip「孕期」(`radius.pill` + `glass.fill.roseSoft`) + 「孕16周」`type.display`
- 右侧：孕妈妈剪影插画（保留原风格，可略提亮）

### 5.4 角色卡（四位陪伴 · 2×2）

| 状态 | 填充 | 图标/字 | 角标 |
|---|---|---|---|
| 激活（小暖） | `glass.fill.rose` | 正常色 | 绿点「在线」 |
| 锁定 | `glass.fill.locked` | `color.locked.icon` | 锁图标 +「后续版本开放」 |

圆角 `radius.lg`，内边距 `space.lg`。

### 5.5 聊天气泡

| 角色 | 材质 | 文字 |
|---|---|---|
| 用户 | `glass.fill.rose` + 右下连续圆角 | `color.text.onAccent` |
| 助手 | `glass.fill.light` + 描边 + 左下连续圆角 | `color.text.primary` |

- 最大宽度：屏宽 ~78%
- 来源行：`type.caption` + `color.text.secondary`，在助手气泡下方
- 头像：圆形 + 细玻璃环描边

### 5.6 输入条

- 悬浮胶囊：`glass.fill.medium` + `radius.pill` + `shadow.float`
- 边框：可选 `1px` `rgba(232,165,152,0.45)`
- 发送按钮：玫瑰玻璃小方/胶囊，文案「发送」或纸飞机图标
- 底部安全区：与底栏同样避开系统手势区

### 5.7 设置列表（我的）

- 单组 iOS Settings 风格玻璃卡：`glass.fill.heavy`（可读性优先）
- 行高 ~52–56；左图标在 `radius.md` 的玫瑰浅井里
- 分割线：`color.divider`，左右缩进对齐文字（不顶到图标）

### 5.8 弹窗 Sheet（隐私说明）

- 居中或偏下：`glass.fill.heavy` + `glass.blur=32` + `radius.sheet` + `shadow.sheet`
- 背后：背景高斯模糊 + `scrim.modal`
- 主按钮：「同意并继续」→ 实心偏玻璃玫瑰（可垂直轻微高光），圆角 `radius.md`
- 次操作：「关闭」→ 纯文字 `color.text.secondary`

---

## 6. 动效（Motion）

| Token / 场景 | 曲线 | 时长 | 说明 |
|---|---|---|---|
| `motion.standard` | `cubic-bezier(0.22, 1, 0.36, 1)`（近似 iOS spring ease-out） | `280–320ms` | 页面元素入场、tab 切换 |
| `motion.spring` | Flutter `SpringDescription(mass:1, stiffness:180, damping:18)` | — | 卡片按压回弹、空态图标 |
| `motion.sheet` | ease-out + fade | `320–380ms` | 弹窗出现：scale `0.94→1` + opacity `0→1` |
| `motion.press` | — | `100ms` | 按下 scale `0.97`，透明度略降 |
| `motion.blur` | — | 与 sheet 同步 | 打开弹窗时背后 blur `0→16+` |

原则：

- 列表/卡片入场：轻微 `translateY(12→0)` + fade，交错 delay `40ms`
- 气泡入场：从侧向 `8dp` + fade（用户右侧、助手左侧）
- 禁止循环闪烁、强弹跳超过一次

---

## 7. 屏幕映射（对照 mockup）

| 屏幕 | 原版 | 玻璃版参考 | 关键组件 |
|---|---|---|---|
| 首页 | `../p1-01-home.png` | `p1-01-home-glass.png` | 英雄卡、角色网格、任务卡、悬浮底栏 |
| 小暖对话 | `../p1-02-chat-xiaonuan.png` | `p1-02-chat-xiaonuan-glass.png` | 玻璃顶栏、气泡、输入胶囊 |
| 林医生锁定 | `../p1-03-chat-lin-locked.png` | `p1-03-chat-lin-locked-glass.png` | 信息 chip、空态插画、禁用输入 |
| 对话空态 | `../p1-04-conversations-empty.png` | `p1-04-conversations-empty-glass.png` | 空态图标井、悬浮底栏 |
| 我的 | `../p1-05-me-info.png` | `p1-05-me-info-glass.png` | 设置玻璃分组列表 |
| 隐私弹窗 | `../p1-06-privacy-dialog.png` | `p1-06-privacy-dialog-glass.png` | Sheet + scrim + 健康卡（背后） |

生成代码时：**以玻璃版 PNG 为视觉验收标准**，以本文 Token 为数值标准。

---

## 8. Flutter 落地提示（非强制实现，供生成代码对齐）

```dart
// 伪代码：标准玻璃容器
ClipRRect(
  borderRadius: BorderRadius.circular(RadiusTokens.lg),
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: GlassTokens.fillLight, // rgba white 0.55
        borderRadius: BorderRadius.circular(RadiusTokens.lg),
        border: Border.all(color: GlassTokens.stroke, width: 1),
        boxShadow: ShadowTokens.card,
      ),
      child: child,
    ),
  ),
)
```

建议主题结构：

- `AppColors` / `GlassTokens` / `RadiusTokens` / `ShadowTokens` / `MotionTokens`
- 通用组件：`GlassCard`、`GlassAppBar`、`GlassTabBar`、`GlassTextField`、`GlassSheet`
- 性能：列表长页可对非视口卡降级为半透明无 blur；弹窗与底栏保持真实 blur

---

## 9. 明确禁止（避免生成跑偏）

- 紫–靛渐变、霓虹描边、暗黑默认主题
- 实色大白卡片冒充「玻璃」（无透明度/无模糊）
- 卡片堆叠过多描边 + 过重 elevation 导致「脏」
- 在首屏堆统计条、促销徽章、贴纸式浮标
- 改变信息架构（隐藏四角色、改 Tab 数量等）——视觉升级不等于改产品结构

---

## 10. 变更记录

| 日期 | 说明 |
|---|---|
| 2026-09-08 | 初版：由原扁平 mockup 升级为苹果玻璃磨砂参数，并导出 6 张 glass 参考图 |
| 2026-09-08 | 按 Claude Design / Stitch 规范导出根目录 `DESIGN.md`；用其 Token 再生 6 张图至 `from-design-md/` |
