#include <string.h>

void __wrap_pntest_(
    float *energy,
    int *reaction,
    float *real_part,
    float *imag_part,
    int *title)
{
    const unsigned char invalid_title[4] = {31, 'P', '0', '0'};

    (void)energy;
    (void)reaction;
    (void)real_part;
    (void)imag_part;
    memcpy(&title[0], invalid_title, sizeof(invalid_title));
}
