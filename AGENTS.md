# 魔方钢珠迷宫

Flutter 3D 益智游戏。玩家旋转 4×4×4 魔方，利用重力让钢珠沿管道从绿色起点 `(0,0,0)` 滚到金色终点 `(3,3,3)`，共 9 关。

## 运行

Flutter SDK 位于 `D:\flutter_windows_3.44.1-stable\flutter`，未加入系统 PATH，所有 flutter 命令须用完整路径：

```powershell
# 在 Chrome 中运行（推荐，无需额外工具）
D:\flutter_windows_3.44.1-stable\flutter\bin\flutter.bat run -d chrome

# 热重载（应用运行时按 r）/ 热重启（按 R）
```

首次运行前若缺少平台文件：
```powershell
D:\flutter_windows_3.44.1-stable\flutter\bin\flutter.bat create . --project-name cube_maze
D:\flutter_windows_3.44.1-stable\flutter\bin\flutter.bat pub get
```

## 项目结构

```
lib/
  main.dart                   # 入口，MaterialApp + ProviderScope
  models/                     # 数据模型
    game_cube.dart            # 4×4×4 方块网格
    cube_block.dart           # 单个方块，face mask 编码管道连通
    game_state.dart           # 游戏状态（球位置、朝向、动画阶段）
    game_level.dart           # 关卡定义（从 JSON 加载）
    face.dart                 # Face 枚举 + deltaToFace map（final，非 const）
    pipe_type.dart            # 管道类型枚举
  services/
    level_loader.dart         # 用 AssetManifest API 加载关卡 JSON
    gravity_solver.dart       # 根据旋转方向计算钢珠下一步
  providers/
    game_provider.dart        # Riverpod 状态管理
  rendering/
    cube_painter.dart         # CustomPainter 等轴测 3D 渲染
  widgets/
    cube_widget.dart          # 手势 + 动画
    game_screen.dart          # 游戏主界面
    level_select_screen.dart  # 关卡选择
    solved_overlay.dart       # 通关弹窗
  utils/
    coordinate.dart           # 三维坐标，实现 == / hashCode
    arcball.dart              # 弧球旋转计算

assets/levels/                # level_001.json ~ level_009.json
```

## 关键设计决策

- **Face mask 编码**：每个方块用 6 位 bitmask 表示开口面（top=0x01, bottom=0x02, right=0x04, left=0x08, front=0x10, back=0x20），两格相邻且互有对应面才连通。
- **AssetManifest**：使用 `AssetManifest.loadFromAssetBundle(rootBundle)` 而非旧版 `rootBundle.loadString('AssetManifest.json')`（Flutter 3.x 已废弃后者）。
- **deltaToFace**：声明为 `final` 而非 `const`，因为 `Coordinate` key 无编译时原始相等性。
- **状态管理**：Riverpod `StateNotifierProvider`，关卡切换时重建 `GameNotifier`。

## 添加关卡

在 `assets/levels/` 新增 JSON 文件，格式参考现有关卡。face mask 编码：

| 面     | 值   |
|--------|------|
| top    | 0x01 |
| bottom | 0x02 |
| right  | 0x04 |
| left   | 0x08 |
| front  | 0x10 |
| back   | 0x20 |

两格相邻且都有对应面的 mask 才会连通（例如 A.right=0x04 且 B.left=0x08）。
