#include<stdio.h>
#include<unistd.h>
#include<string.h>

void ProcBar()
{
    int rate = 0;
    char str[102];
    memset(str, 0, 102 * sizeof(char));
    const char* ptr = "|/-\\";
    while(rate < 100)
    {
        str[rate] = '=';
        rate++;
        printf("[%-100s][%d%%][%c]\r", str, rate, ptr[rate % 4]);
        usleep(200000);
        fflush(stdout);
    }
    printf("\n");
}

int main()
{
    ProcBar();
    return 0;
}

// =====================================================================================================
