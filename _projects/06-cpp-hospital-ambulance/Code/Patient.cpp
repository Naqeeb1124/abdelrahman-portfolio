#include "Patient.h"

Patient::Patient(std::string p_type, int qt, int pid, int hid, int dst, int svr) {
    this->p_type = p_type;
    this->qt = qt;
    this->pid = pid;
    this->hid = hid;
    this->dst = dst;
    this->svr = svr;
    this->at = 0;
    this->pt = 0;
    this->ft = 0;
    this->wt = 0;
    this->car_id = "";
}

void Patient::calculate_wt() {
    this->wt = this->pt - this->qt;
}

void Patient::calculate_ft(int car_speed) {
    this->ft = this->pt + (this->dst / car_speed);
}


