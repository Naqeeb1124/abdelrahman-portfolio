#include "AmbulanceSystem.h"
#include <iostream>
#include <string>

using namespace std;

int main() {
    cout << "Ambulance Management System" << endl;
    cout << "Select mode:" << endl;
    cout << "1. Interactive Mode" << endl;
    cout << "2. Silent Mode" << endl;
    cout << "Enter your choice (1 or 2): ";

    int choice;
    cin >> choice;
    cin.ignore();

    bool interactive = (choice == 1);

    cout << "Enter input filename: ";
    string inputFile;
    getline(cin, inputFile);

    cout << "Enter output filename: ";
    string outputFile;
    getline(cin, outputFile);

    AmbulanceSystem system;

    if (!system.loadFromFile(inputFile)) {
        cerr << "Failed to load input file: " << inputFile << endl;
        return 1;
    }

    system.runSimulation(interactive);
    system.saveOutputFile(outputFile);

    return 0;
}