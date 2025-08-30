#ifndef OPERATION_H
#define OPERATION_H

class GUI;
class ApplicationManager;

// Base class for all operations
class Operation {
protected:
    ApplicationManager* appManager;

public:
    // Constructor
    Operation(ApplicationManager* pApp);

    // Virtual destructor
    virtual ~Operation();

    // Pure virtual function to be implemented by derived classes
    virtual void Act() = 0;
};

#endif
