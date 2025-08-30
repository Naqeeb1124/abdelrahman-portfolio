#ifndef CAR_H
#define CAR_H

#include <string>
#include "Patient.h"

class Car {
public:
    std::string c_type;
    int speed;
    std::string car_id;
    int hospital_id;
    std::string status;
    Patient* current_patient;
    int busy_time;

    Car(std::string c_type, int speed, std::string car_id, int hospital_id);

    void assign_patient(Patient* patient);
    void pick_patient();
    void return_to_hospital();
};

#endif // CAR_H


