#include "ApplicationManager.h"
#include <iostream>

using namespace std;

int main() {
    try {
        // Create application manager and run the game
        ApplicationManager app;

        cout << "=== Shape Hunt Game ===" << endl;
        cout << "Welcome to the Shape Hunt Game!" << endl;
        cout << "Instructions:" << endl;
        cout << "1. Click on shapes in the toolbar to create them" << endl;
        cout << "2. Click on shapes to select them" << endl;
        cout << "3. Use operations (rotate, resize, flip, delete) on selected shapes" << endl;
        cout << "4. Press SPACEBAR to check if your shape matches a target" << endl;
        cout << "5. Match all target shapes to advance to the next level" << endl;
        cout << "6. Starting from level 3, shapes will be black (harder!)" << endl;
        cout << "Starting game..." << endl;

        app.Run();

        cout << "Game ended. Thanks for playing!" << endl;
    }
    catch(const exception& e) {
        cout << "Error: " << e.what() << endl;
        return 1;
    }

    return 0;
}
