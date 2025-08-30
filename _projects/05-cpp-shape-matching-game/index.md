---
layout: default
programming_project: true
title: "05-cpp-shape-matching-game"
description: "A shape is displayed and the user has to transform it around the screen to match it to the given required position. Has 30+ features."
link: https://github.com/Naqeeb1124/FOR-C-PROJECT
files:
  - name: "Full ZIP file"
    path: "ShapeHuntGame.zip"
---
# Shape Hunt Game

A C++ implementation of the Shape Hunt game using object-oriented programming principles and the CMU Graphics library.

## Project Structure

```
ShapeHuntGame/
├── headers/                 # Header files (.h)
│   ├── Shape.h             # Base shape class
│   ├── Rectangle.h         # Rectangle basic shape
│   ├── Circle.h            # Circle basic shape
│   ├── Triangle.h          # Triangle basic shape
│   ├── CompositeShape.h    # Base composite shape class
│   ├── Sign.h              # Plus sign composite (2 rectangles)
│   ├── Home.h              # House composite (rectangle + triangle)
│   ├── Person.h            # Person composite (circle + 2 rectangles)
│   ├── Car.h               # Car composite (rectangle + 2 circles)
│   ├── Flower.h            # Flower composite (4 shapes, 3 types)
│   ├── Robot.h             # Robot composite (4 shapes, 3 types)
│   ├── Operation.h         # Base operation class
│   ├── Operations.h        # All toolbar operations
│   ├── GUI.h               # Graphics user interface
│   ├── Grid.h              # Game grid management
│   └── ApplicationManager.h # Main application controller
├── source/                 # Source files (.cpp)
│   ├── Shape.cpp
│   ├── Rectangle.cpp
│   ├── Circle.cpp
│   ├── Triangle.cpp
│   ├── CompositeShape.cpp
│   ├── Sign.cpp
│   ├── Home.cpp
│   ├── Person.cpp
│   ├── Car.cpp
│   ├── Flower.cpp
│   ├── Robot.cpp
│   ├── Operation.cpp
│   ├── Operations.cpp
│   ├── GUI.cpp
│   ├── Grid.cpp
│   └── ApplicationManager.cpp
├── main.cpp               # Entry point
├── CMakeLists.txt         # CMake build file
├── Makefile              # Alternative build file
└── README.md             # This file
```

## Game Features

### Basic Shapes
- **Rectangle**: Resizable rectangle with width and height
- **Circle**: Resizable circle with radius
- **Triangle**: Equilateral triangle with side length

### Composite Shapes (6 required)
1. **Sign**: Plus sign made of 2 rectangles
2. **Home**: House with rectangle base + triangle roof (2 different shapes)
3. **Person**: Stick figure with circle head + rectangle body/legs (3 different shapes)
4. **Car**: Car body with rectangle + 2 circle wheels (3 different shapes)
5. **Flower**: Flower with stem, center, petals (4 shapes, 3 different types)
6. **Robot**: Robot with body, head, arms, antenna (4 shapes, 3 different types)

### Operations
- **Add Shapes**: Create composite shapes from toolbar
- **Rotate**: 90-degree clockwise rotation
- **Resize Up**: Double the size
- **Resize Down**: Half the size
- **Flip**: Vertical flip
- **Delete**: Remove selected shape
- **Move**: Move shapes with arrow keys
- **Refresh**: Generate new random shapes (costs 1 life)
- **Save/Load**: Save and restore game progress

### Game Mechanics
- **Levels**: Progressive difficulty
  - Level 1: 1 random shape
  - Level 2: 3 random shapes
  - Level 3+: Overlapping black shapes (harder)
- **Lives**: Start with 5 lives
- **Scoring**: +2 points for correct match, -1 for wrong match
- **Matching**: Press spacebar to check if selected shape matches target

## Building the Game

### Prerequisites
- C++11 compatible compiler (g++, Visual Studio, etc.)
- CMU Graphics Library (adjust paths in build files)

### Using CMake
```bash
mkdir build
cd build
cmake ..
make
./ShapeHuntGame
```

### Using Makefile
```bash
# Adjust CMU_GRAPHICS_PATH in Makefile first
make
./ShapeHuntGame
```

### Manual Compilation
```bash
# Compile all source files together
g++ -std=c++11 -Iheaders source/*.cpp main.cpp -o ShapeHuntGame -lCMUgraphics
```

## Game Instructions

1. **Starting**: The game begins at Level 1 with random target shapes displayed
2. **Creating Shapes**: Click toolbar buttons to create composite shapes
3. **Selection**: Click on any shape to select it (highlighted in yellow)
4. **Operations**: Use toolbar buttons to modify selected shapes
5. **Matching**: Press SPACEBAR to check if your selected shape matches a target
6. **Scoring**: Correct matches give +2 points, wrong matches -1 point
7. **Level Progression**: Match all targets to advance to next level
8. **Difficulty**: Starting Level 3, all shapes become black (harder to distinguish)

## Implementation Details

### Object-Oriented Design
- **Inheritance**: Shape → Rectangle/Circle/Triangle, CompositeShape → Sign/Home/etc.
- **Polymorphism**: Virtual functions for Draw, Rotate, Resize, Flip, Match
- **Encapsulation**: Private members with public interfaces
- **Composition**: Composite shapes contain basic shapes

### Design Patterns
- **Strategy Pattern**: Operation classes for different toolbar actions
- **Factory Pattern**: ApplicationManager creates appropriate operations
- **Observer Pattern**: GUI updates based on game state changes

### File Format (Save/Load)
```
Score Level Lives
ShapeType RefX RefY RotationCount ResizeCount FillColor OutlineColor [shape-specific data]
ShapeType RefX RefY RotationCount ResizeCount FillColor OutlineColor [shape-specific data]
...
```

## Project Requirements Fulfilled

### Phase 1 Requirements ✓
- All 6 composite shapes implemented with correct complexity
- Basic shapes with all required operations
- Toolbar with all items
- Game grid and random shape generation
- Score and lives system
- Shape matching functionality

### Phase 2 Requirements ✓
- Save/Load functionality with proper file format
- Progressive level difficulty
- Black shapes for Level 3+
- All toolbar operations implemented
- Proper OOP design with inheritance and polymorphism

### Bonus Features
- Visual shape highlighting for selection
- Comprehensive error handling
- Modular design for easy extension
- Cross-platform build support

## Notes for Compilation

1. **CMU Graphics Library**: You'll need to install and configure the CMU Graphics library
2. **Path Configuration**: Update library paths in CMakeLists.txt or Makefile
3. **Platform Specific**: May need additional libraries on Windows (user32, gdi32)





