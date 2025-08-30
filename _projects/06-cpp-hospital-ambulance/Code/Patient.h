#ifndef PATIENT_H
#define PATIENT_H

#include <string>

class Patient {
public:
    std::string p_type;
    int qt;
    int pid;
    int hid;
    int dst;
    int svr; // Severity for EP patients, 0 if not EP
    int at;  // Assignment Time
    int pt;  // Pickup Time
    int ft;  // Finish Time
    int wt;  // Waiting Time
    std::string car_id;

    Patient(std::string p_type, int qt, int pid, int hid, int dst, int svr = 0);

    void calculate_wt();
    void calculate_ft(int car_speed);
};

#endif // PATIENT_H


