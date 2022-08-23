//Given a local first argument

void good_use(){
    //Raises Warning
    KEVENT kevent1;
    KeWaitForSingleObject(&kevent1, UserRequest, UserMode, FALSE, NULL);
}

void bad_use(){
    //Avoids warning as it's AccessMode is KernelMode for a local first argument, kevent2.
    KEVENT kevent2;
    KeWaitForSingleObject(&kevent2, UserRequest, KernelMode, FALSE, NULL);
}

void top_level_call() {
    good_use();
    bad_use();
}