#ifndef GRID_H
#define GRID_H

#include "Shape.h"
#include "GUI.h"
#include <vector>

class Grid {
private:
    std::vector<Shape*> randomShapes;    // Random shapes for the current level
    std::vector<Shape*> playerShapes;    // Shapes created by player
    Shape* selectedShape;                // Currently selected shape
    int currentLevel;
    int score;
    int lives;
    int targetMatches;                   // Number of matches needed to advance
    int currentMatches;                  // Current matches made

public:
    // Constructor
    Grid();

    // Destructor
    ~Grid();

    // Shape management
    void AddRandomShape(Shape* shape);
    void AddPlayerShape(Shape* shape);
    void DeleteShape(Shape* shape);
    void ClearRandomShapes();
    void ClearPlayerShapes();
    void ClearAllShapes();

    // Game operations
    void GenerateRandomShapes();
    void SetLevel(int level);
    bool CheckMatch(Shape* playerShape);
    void RefreshLevel();

    // Selection and interaction
    Shape* GetShapeAt(Point p);
    void SetSelectedShape(Shape* shape);
    Shape* GetSelectedShape() const { return selectedShape; }

    // Drawing
    void Draw(GUI* pGUI) const;

    // Game state
    int GetScore() const { return score; }
    int GetLives() const { return lives; }
    int GetLevel() const { return currentLevel; }
    int GetRemainingShapes() const { return randomShapes.size(); }

    void UpdateScore(int points) { score += points; }
    void LoseLife() { if(lives > 0) lives--; }
    void NextLevel();

    // Utility
    Point GetRandomGridPosition() const;
    bool IsPositionValid(Point p, Shape* shape) const;
    void ApplyBlackFill(); // For level 3+

private:
    void CalculateTargetMatches();
    Shape* CreateRandomCompositeShape();
};

#endif
