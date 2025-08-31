#ifndef OPERATIONS_H
#define OPERATIONS_H

#include "Operation.h"
#include "ApplicationManager.h"
#include "Shape.h"

// Add Sign operation
class OperAddSign : public Operation {
public:
    OperAddSign(ApplicationManager* pApp);
    virtual void Act() override;
};

// Add Home operation
class OperAddHome : public Operation {
public:
    OperAddHome(ApplicationManager* pApp);
    virtual void Act() override;
};

// Add Person operation
class OperAddPerson : public Operation {
public:
    OperAddPerson(ApplicationManager* pApp);
    virtual void Act() override;
};

// Add Car operation
class OperAddCar : public Operation {
public:
    OperAddCar(ApplicationManager* pApp);
    virtual void Act() override;
};

// Add Flower operation
class OperAddFlower : public Operation {
public:
    OperAddFlower(ApplicationManager* pApp);
    virtual void Act() override;
};

// Add Robot operation
class OperAddRobot : public Operation {
public:
    OperAddRobot(ApplicationManager* pApp);
    virtual void Act() override;
};

// Rotate operation
class OperRotate : public Operation {
public:
    OperRotate(ApplicationManager* pApp);
    virtual void Act() override;
};

// Resize Up operation
class OperResizeUp : public Operation {
public:
    OperResizeUp(ApplicationManager* pApp);
    virtual void Act() override;
};

// Resize Down operation
class OperResizeDown : public Operation {
public:
    OperResizeDown(ApplicationManager* pApp);
    virtual void Act() override;
};

// Flip operation
class OperFlip : public Operation {
public:
    OperFlip(ApplicationManager* pApp);
    virtual void Act() override;
};

// Delete operation
class OperDelete : public Operation {
public:
    OperDelete(ApplicationManager* pApp);
    virtual void Act() override;
};

// Save operation
class OperSave : public Operation {
public:
    OperSave(ApplicationManager* pApp);
    virtual void Act() override;
};

// Load operation
class OperLoad : public Operation {
public:
    OperLoad(ApplicationManager* pApp);
    virtual void Act() override;
};

// Refresh operation
class OperRefresh : public Operation {
public:
    OperRefresh(ApplicationManager* pApp);
    virtual void Act() override;
};

// Exit operation
class OperExit : public Operation {
public:
    OperExit(ApplicationManager* pApp);
    virtual void Act() override;
};

#endif
