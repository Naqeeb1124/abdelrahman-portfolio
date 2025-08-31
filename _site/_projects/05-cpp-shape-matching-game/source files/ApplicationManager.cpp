#include "ApplicationManager.h"
#include "Operations.h"
#include <iostream>

using namespace std;

// Constructor
ApplicationManager::ApplicationManager() {
    pGUI = new GUI();
    pGrid = new Grid();
    pOperation = nullptr;
    gameRunning = true;
}

// Destructor
ApplicationManager::~ApplicationManager() {
    delete pGUI;
    delete pGrid;
    delete pOperation;
}

// Main game loop
void ApplicationManager::Run() {
    UpdateDisplay();

    while(gameRunning) {
        ToolbarItem item = pGUI->GetUserClick();

        if(item != ITM_INVALID) {
            ExecuteOperation(item);
            UpdateDisplay();
        }

        // Handle spacebar for matching
        char key;
        if(pGUI->GetKeyPressed(key)) {
            if(key == ' ') {
                // Space bar pressed - check for match
                Shape* selected = pGrid->GetSelectedShape();
                if(selected) {
                    bool matched = pGrid->CheckMatch(selected);
                    if(matched) {
                        pGUI->UpdateStatusBar("Shape matched successfully! +2 points");
                    } else {
                        pGUI->UpdateStatusBar("No match found. -1 point");
                    }
                    UpdateDisplay();
                }
            }
        }
    }
}

// Execute operation based on toolbar item
void ApplicationManager::ExecuteOperation(ToolbarItem item) {
    delete pOperation; // Delete previous operation
    pOperation = CreateOperation(item);

    if(pOperation) {
        pOperation->Act();

        // Update status bar with operation message
        string message = "Operation completed: ";
        switch(item) {
            case ITM_SIGN: message += "Sign added"; break;
            case ITM_HOME: message += "Home added"; break;
            case ITM_PERSON: message += "Person added"; break;
            case ITM_CAR: message += "Car added"; break;
            case ITM_FLOWER: message += "Flower added"; break;
            case ITM_ROBOT: message += "Robot added"; break;
            case ITM_ROTATE: message += "Shape rotated"; break;
            case ITM_RESIZE_UP: message += "Shape enlarged"; break;
            case ITM_RESIZE_DOWN: message += "Shape shrunk"; break;
            case ITM_FLIP: message += "Shape flipped"; break;
            case ITM_DELETE: message += "Shape deleted"; break;
            case ITM_REFRESH: message += "Level refreshed"; break;
            case ITM_SAVE: message += "Game saved"; break;
            case ITM_LOAD: message += "Game loaded"; break;
            default: message += "Unknown operation"; break;
        }
        pGUI->UpdateStatusBar(message);
    }
}

// Update display
void ApplicationManager::UpdateDisplay() {
    pGUI->ClearGridArea();
    pGUI->DrawToolbar();
    pGUI->DrawStatusBar();
    pGrid->Draw(pGUI);

    // Display game status
    pGUI->DisplayScore(pGrid->GetScore());
    pGUI->DisplayLives(pGrid->GetLives());
    pGUI->DisplayLevel(pGrid->GetLevel());
}

// Handle key press
void ApplicationManager::HandleKeyPress(char key) {
    // Implementation can be expanded for more key handling
}

// Handle mouse click
void ApplicationManager::HandleMouseClick(Point p) {
    Shape* clickedShape = pGrid->GetShapeAt(p);
    pGrid->SetSelectedShape(clickedShape);
}

// Save game
void ApplicationManager::SaveGame(const string& filename) {
    ofstream outFile(filename);
    if(outFile.is_open()) {
        // Save game state
        outFile << pGrid->GetScore() << " " << pGrid->GetLevel() << " " << pGrid->GetLives() << "\n";

        // Note: Shape saving would require additional implementation
        // This is a basic structure

        outFile.close();
    }
}

// Load game
void ApplicationManager::LoadGame(const string& filename) {
    ifstream inFile(filename);
    if(inFile.is_open()) {
        // Load game state
        int score, level, lives;
        inFile >> score >> level >> lives;

        // Note: Shape loading would require additional implementation
        // This is a basic structure

        inFile.close();
    }
}

// Create operation based on toolbar item
Operation* ApplicationManager::CreateOperation(ToolbarItem item) {
    switch(item) {
        case ITM_SIGN: return new OperAddSign(this);
        case ITM_HOME: return new OperAddHome(this);
        case ITM_PERSON: return new OperAddPerson(this);
        case ITM_CAR: return new OperAddCar(this);
        case ITM_FLOWER: return new OperAddFlower(this);
        case ITM_ROBOT: return new OperAddRobot(this);
        case ITM_ROTATE: return new OperRotate(this);
        case ITM_RESIZE_UP: return new OperResizeUp(this);
        case ITM_RESIZE_DOWN: return new OperResizeDown(this);
        case ITM_FLIP: return new OperFlip(this);
        case ITM_DELETE: return new OperDelete(this);
        case ITM_REFRESH: return new OperRefresh(this);
        case ITM_SAVE: return new OperSave(this);
        case ITM_LOAD: return new OperLoad(this);
        case ITM_EXIT: return new OperExit(this);
        default: return nullptr;
    }
}
