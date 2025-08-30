#ifndef APPLICATION_MANAGER_H
#define APPLICATION_MANAGER_H

#include "GUI.h"
#include "Grid.h"
#include "Operation.h"

class ApplicationManager {
private:
    GUI* pGUI;
    Grid* pGrid;
    Operation* pOperation;
    bool gameRunning;

public:
    // Constructor
    ApplicationManager();

    // Destructor
    ~ApplicationManager();

    // Main game loop
    void Run();

    // Getters
    GUI* GetGUI() const { return pGUI; }
    Grid* GetGrid() const { return pGrid; }

    // Game operations
    void ExecuteOperation(ToolbarItem item);
    void UpdateDisplay();
    void HandleKeyPress(char key);
    void HandleMouseClick(Point p);

    // Game state
    void SaveGame(const string& filename);
    void LoadGame(const string& filename);
    void ExitGame() { gameRunning = false; }

private:
    Operation* CreateOperation(ToolbarItem item);
};

#endif
