#include "Operations.h"
#include "Sign.h"
#include "Home.h"
#include "Person.h"
#include "Car.h"
#include "Flower.h"
#include "Robot.h"

// OperAddSign implementation
OperAddSign::OperAddSign(ApplicationManager* pApp) : Operation(pApp) {}

void OperAddSign::Act() {
    Shape* sign = new Sign(Point(300, 300));
    appManager->GetGrid()->AddPlayerShape(sign);
}

// OperAddHome implementation
OperAddHome::OperAddHome(ApplicationManager* pApp) : Operation(pApp) {}

void OperAddHome::Act() {
    Shape* home = new Home(Point(300, 300));
    appManager->GetGrid()->AddPlayerShape(home);
}

// OperAddPerson implementation
OperAddPerson::OperAddPerson(ApplicationManager* pApp) : Operation(pApp) {}

void OperAddPerson::Act() {
    Shape* person = new Person(Point(300, 300));
    appManager->GetGrid()->AddPlayerShape(person);
}

// OperAddCar implementation
OperAddCar::OperAddCar(ApplicationManager* pApp) : Operation(pApp) {}

void OperAddCar::Act() {
    Shape* car = new Car(Point(300, 300));
    appManager->GetGrid()->AddPlayerShape(car);
}

// OperAddFlower implementation
OperAddFlower::OperAddFlower(ApplicationManager* pApp) : Operation(pApp) {}

void OperAddFlower::Act() {
    Shape* flower = new Flower(Point(300, 300));
    appManager->GetGrid()->AddPlayerShape(flower);
}

// OperAddRobot implementation
OperAddRobot::OperAddRobot(ApplicationManager* pApp) : Operation(pApp) {}

void OperAddRobot::Act() {
    Shape* robot = new Robot(Point(300, 300));
    appManager->GetGrid()->AddPlayerShape(robot);
}

// OperRotate implementation
OperRotate::OperRotate(ApplicationManager* pApp) : Operation(pApp) {}

void OperRotate::Act() {
    Shape* selected = appManager->GetGrid()->GetSelectedShape();
    if(selected) {
        selected->Rotate();
    }
}

// OperResizeUp implementation
OperResizeUp::OperResizeUp(ApplicationManager* pApp) : Operation(pApp) {}

void OperResizeUp::Act() {
    Shape* selected = appManager->GetGrid()->GetSelectedShape();
    if(selected) {
        selected->ResizeUp();
    }
}

// OperResizeDown implementation
OperResizeDown::OperResizeDown(ApplicationManager* pApp) : Operation(pApp) {}

void OperResizeDown::Act() {
    Shape* selected = appManager->GetGrid()->GetSelectedShape();
    if(selected) {
        selected->ResizeDown();
    }
}

// OperFlip implementation
OperFlip::OperFlip(ApplicationManager* pApp) : Operation(pApp) {}

void OperFlip::Act() {
    Shape* selected = appManager->GetGrid()->GetSelectedShape();
    if(selected) {
        selected->Flip();
    }
}

// OperDelete implementation
OperDelete::OperDelete(ApplicationManager* pApp) : Operation(pApp) {}

void OperDelete::Act() {
    Shape* selected = appManager->GetGrid()->GetSelectedShape();
    if(selected) {
        appManager->GetGrid()->DeleteShape(selected);
        appManager->GetGrid()->SetSelectedShape(nullptr);
    }
}

// OperSave implementation
OperSave::OperSave(ApplicationManager* pApp) : Operation(pApp) {}

void OperSave::Act() {
    appManager->SaveGame("savegame.txt");
}

// OperLoad implementation
OperLoad::OperLoad(ApplicationManager* pApp) : Operation(pApp) {}

void OperLoad::Act() {
    appManager->LoadGame("savegame.txt");
}

// OperRefresh implementation
OperRefresh::OperRefresh(ApplicationManager* pApp) : Operation(pApp) {}

void OperRefresh::Act() {
    appManager->GetGrid()->RefreshLevel();
}

// OperExit implementation
OperExit::OperExit(ApplicationManager* pApp) : Operation(pApp) {}

void OperExit::Act() {
    appManager->ExitGame();
}
