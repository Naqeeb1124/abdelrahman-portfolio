#include "GUI.h"
#include <sstream>

// Constructor
GUI::GUI() {
    pWind = CreateWind(WINDOW_WIDTH, WINDOW_HEIGHT, 0, 0);
    pWind->SetPen(BLACK_COLOR, 2);
    pWind->SetBrush(WHITE_COLOR);
}

// Destructor
GUI::~GUI() {
    delete pWind;
}

// Draw the toolbar
void GUI::DrawToolbar() const {
    // Clear toolbar area
    pWind->SetBrush(LIGHTGRAY_COLOR);
    pWind->DrawRectangle(0, 0, WINDOW_WIDTH, TOOLBAR_HEIGHT, FILLED);

    // Draw toolbar items
    int itemWidth = WINDOW_WIDTH / 18; // 18 items total
    int x = 10;
    int y = 10;

    // Shape icons
    pWind->SetBrush(YELLOW_COLOR);
    pWind->DrawRectangle(x, y, x + itemWidth - 5, y + TOOLBAR_HEIGHT - 20, FILLED);
    pWind->DrawString(x + 5, y + 25, "Sign", BLACK_COLOR);
    x += itemWidth;

    pWind->SetBrush(RED_COLOR);
    pWind->DrawRectangle(x, y, x + itemWidth - 5, y + TOOLBAR_HEIGHT - 20, FILLED);
    pWind->DrawString(x + 5, y + 25, "Home", BLACK_COLOR);
    x += itemWidth;

    pWind->SetBrush(BLUE_COLOR);
    pWind->DrawRectangle(x, y, x + itemWidth - 5, y + TOOLBAR_HEIGHT - 20, FILLED);
    pWind->DrawString(x + 5, y + 25, "Person", BLACK_COLOR);
    x += itemWidth;

    pWind->SetBrush(GREEN_COLOR);
    pWind->DrawRectangle(x, y, x + itemWidth - 5, y + TOOLBAR_HEIGHT - 20, FILLED);
    pWind->DrawString(x + 5, y + 25, "Car", BLACK_COLOR);
    x += itemWidth;

    pWind->SetBrush(PURPLE_COLOR);
    pWind->DrawRectangle(x, y, x + itemWidth - 5, y + TOOLBAR_HEIGHT - 20, FILLED);
    pWind->DrawString(x + 5, y + 25, "Flower", BLACK_COLOR);
    x += itemWidth;

    pWind->SetBrush(ORANGE_COLOR);
    pWind->DrawRectangle(x, y, x + itemWidth - 5, y + TOOLBAR_HEIGHT - 20, FILLED);
    pWind->DrawString(x + 5, y + 25, "Robot", BLACK_COLOR);
    x += itemWidth;

    // Operation icons
    pWind->SetBrush(LIGHTBLUE_COLOR);
    pWind->DrawRectangle(x, y, x + itemWidth - 5, y + TOOLBAR_HEIGHT - 20, FILLED);
    pWind->DrawString(x + 5, y + 25, "Rotate", BLACK_COLOR);
    x += itemWidth;

    pWind->DrawRectangle(x, y, x + itemWidth - 5, y + TOOLBAR_HEIGHT - 20, FILLED);
    pWind->DrawString(x + 5, y + 25, "Size+", BLACK_COLOR);
    x += itemWidth;

    pWind->DrawRectangle(x, y, x + itemWidth - 5, y + TOOLBAR_HEIGHT - 20, FILLED);
    pWind->DrawString(x + 5, y + 25, "Size-", BLACK_COLOR);
    x += itemWidth;

    pWind->DrawRectangle(x, y, x + itemWidth - 5, y + TOOLBAR_HEIGHT - 20, FILLED);
    pWind->DrawString(x + 5, y + 25, "Flip", BLACK_COLOR);
    x += itemWidth;

    pWind->DrawRectangle(x, y, x + itemWidth - 5, y + TOOLBAR_HEIGHT - 20, FILLED);
    pWind->DrawString(x + 5, y + 25, "Delete", BLACK_COLOR);
    x += itemWidth;

    pWind->DrawRectangle(x, y, x + itemWidth - 5, y + TOOLBAR_HEIGHT - 20, FILLED);
    pWind->DrawString(x + 5, y + 25, "Refresh", BLACK_COLOR);
    x += itemWidth;

    pWind->DrawRectangle(x, y, x + itemWidth - 5, y + TOOLBAR_HEIGHT - 20, FILLED);
    pWind->DrawString(x + 5, y + 25, "Save", BLACK_COLOR);
    x += itemWidth;

    pWind->DrawRectangle(x, y, x + itemWidth - 5, y + TOOLBAR_HEIGHT - 20, FILLED);
    pWind->DrawString(x + 5, y + 25, "Load", BLACK_COLOR);
    x += itemWidth;

    pWind->DrawRectangle(x, y, x + itemWidth - 5, y + TOOLBAR_HEIGHT - 20, FILLED);
    pWind->DrawString(x + 5, y + 25, "Exit", BLACK_COLOR);
}

// Draw the grid area
void GUI::DrawGrid() const {
    // Clear grid area
    pWind->SetBrush(WHITE_COLOR);
    pWind->DrawRectangle(0, TOOLBAR_HEIGHT, WINDOW_WIDTH, 
                        WINDOW_HEIGHT - STATUS_HEIGHT, FILLED);
}

// Draw status bar
void GUI::DrawStatusBar() const {
    pWind->SetBrush(DARKGRAY_COLOR);
    pWind->DrawRectangle(0, WINDOW_HEIGHT - STATUS_HEIGHT, 
                        WINDOW_WIDTH, WINDOW_HEIGHT, FILLED);
}

// Clear grid area only
void GUI::ClearGridArea() const {
    pWind->SetBrush(WHITE_COLOR);
    pWind->DrawRectangle(0, TOOLBAR_HEIGHT, WINDOW_WIDTH, 
                        WINDOW_HEIGHT - STATUS_HEIGHT, FILLED);
}

// Update status bar with message
void GUI::UpdateStatusBar(string message) const {
    // Clear status bar
    pWind->SetBrush(DARKGRAY_COLOR);
    pWind->DrawRectangle(0, WINDOW_HEIGHT - STATUS_HEIGHT, 
                        WINDOW_WIDTH, WINDOW_HEIGHT, FILLED);

    // Draw message
    pWind->DrawString(10, WINDOW_HEIGHT - STATUS_HEIGHT + 15, 
                     message, WHITE_COLOR);
}

// Set pen color
void GUI::SetPenColor(color c) {
    pWind->SetPen(c, 2);
}

// Set brush color
void GUI::SetBrushColor(color c) {
    pWind->SetBrush(c);
}

// Drawing functions
void GUI::DrawRectangle(Point p1, Point p2, DrawingMode mode) const {
    pWind->DrawRectangle(p1.x, p1.y, p2.x, p2.y, mode);
}

void GUI::DrawCircle(Point center, int radius, DrawingMode mode) const {
    pWind->DrawCircle(center.x, center.y, radius, mode);
}

void GUI::DrawTriangle(Point p1, Point p2, Point p3, DrawingMode mode) const {
    pWind->DrawTriangle(p1.x, p1.y, p2.x, p2.y, p3.x, p3.y, mode);
}

void GUI::DrawString(Point p, string text) const {
    pWind->DrawString(p.x, p.y, text);
}

// Get point clicked
void GUI::GetPointClicked(Point& p) const {
    pWind->GetMouseClick(p.x, p.y);
}

// Get key pressed
void GUI::GetKeyPressed(char& key) const {
    pWind->GetKeyPress(key);
}

// Get user click and determine toolbar item
ToolbarItem GUI::GetUserClick() const {
    Point p;
    pWind->GetMouseClick(p.x, p.y);

    if(p.y <= TOOLBAR_HEIGHT) {
        int itemWidth = WINDOW_WIDTH / 18;
        int itemIndex = p.x / itemWidth;

        switch(itemIndex) {
            case 0: return ITM_SIGN;
            case 1: return ITM_HOME;
            case 2: return ITM_PERSON;
            case 3: return ITM_CAR;
            case 4: return ITM_FLOWER;
            case 5: return ITM_ROBOT;
            case 6: return ITM_ROTATE;
            case 7: return ITM_RESIZE_UP;
            case 8: return ITM_RESIZE_DOWN;
            case 9: return ITM_FLIP;
            case 10: return ITM_DELETE;
            case 11: return ITM_REFRESH;
            case 12: return ITM_SAVE;
            case 13: return ITM_LOAD;
            case 14: return ITM_EXIT;
            default: return ITM_INVALID;
        }
    }

    return ITM_INVALID;
}

// Display game information
void GUI::DisplayScore(int score) const {
    ostringstream oss;
    oss << "Score: " << score;
    pWind->DrawString(WINDOW_WIDTH - 200, WINDOW_HEIGHT - 35, 
                     oss.str(), WHITE_COLOR);
}

void GUI::DisplayLives(int lives) const {
    ostringstream oss;
    oss << "Lives: " << lives;
    pWind->DrawString(WINDOW_WIDTH - 300, WINDOW_HEIGHT - 35, 
                     oss.str(), WHITE_COLOR);
}

void GUI::DisplayLevel(int level) const {
    ostringstream oss;
    oss << "Level: " << level;
    pWind->DrawString(WINDOW_WIDTH - 400, WINDOW_HEIGHT - 35, 
                     oss.str(), WHITE_COLOR);
}
