#include "Car.h"

Car::Car(std::string c_type, int speed, std::string car_id, int hospital_id) {
    this->c_type = c_type;
    this->speed = speed;
    this->car_id = car_id;
    this->hospital_id = hospital_id;
    this->status = "Ready";
    this->current_patient = nullptr;
    this->busy_time = 0;
}

void Car::assign_patient(Patient* patient) {
    this->status = "Assigned";
    this->current_patient = patient;
}

void Car::pick_patient() {
    this->status = "Loaded";
}

void Car::return_to_hospital() {
    this->status = "Ready";
    this->current_patient = nullptr;
}


