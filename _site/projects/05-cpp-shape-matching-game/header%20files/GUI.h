#ifndef GUI_H
#define GUI_H

#include "CMUgraphics.h"

// Toolbar items enumeration
enum ToolbarItem {
    // Composite shapes
    ITM_SIGN,
    ITM_HOME, 
    ITM_PERSON,
    ITM_CAR,
    ITM_FLOWER,
    ITM_ROBOT,

    // Operations
    ITM_ROTATE,
    ITM_RESIZE_UP,
    ITM_RESIZE_DOWN,
    ITM_FLIP,
    ITM_DELETE,
    ITM_MOVE,
    ITM_REFRESH,
    ITM_HINT,

    // Game controls
    ITM_LEVEL_SELECT,
    ITM_SAVE,
    ITM_LOAD,
    ITM_EXIT,

    // Invalid item
    ITM_INVALID
};

// Game areas
enum GameArea {
    TOOLBAR_AREA,
    GRID_AREA,
    STATUS_AREA
};

class GUI {
private:
    window* pWind;

public:
    // Constructor
    GUI();

    // Destructor
    ~GUI();

    // Drawing functions
    void DrawToolbar() const;
    void DrawGrid() const;
    void DrawStatusBar() const;
    void ClearGridArea() const;
    void UpdateStatusBar(string message) const;

    // Shape drawing functions
    void SetPenColor(color c);
    void SetBrushColor(color c);
    void DrawRectangle(Point p1, Point p2, DrawingMode mode = FRAME) const;
    void DrawCircle(Point center, int radius, DrawingMode mode = FRAME) const;
    void DrawTriangle(Point p1, Point p2, Point p3, DrawingMode mode = FRAME) const;
    void DrawString(Point p, string text) const;

    // Input functions
    void GetPointClicked(Point& p) const;
    void GetKeyPressed(char& key) const;
    ToolbarItem GetUserClick() const;

    // Game state display
    void DisplayScore(int score) const;
    void DisplayLives(int lives) const;
    void DisplayLevel(int level) const;

    // Constants
    static const int TOOLBAR_HEIGHT = 80;
    static const int STATUS_HEIGHT = 50;
    static const int WINDOW_WIDTH = 1200;
    static const int WINDOW_HEIGHT = 700;
    static const int GRID_WIDTH = WINDOW_WIDTH;
    static const int GRID_HEIGHT = WINDOW_HEIGHT - TOOLBAR_HEIGHT - STATUS_HEIGHT;
};

#endif
