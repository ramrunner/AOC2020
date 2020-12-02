#include <stdio.h>
#include <assert.h>
#include <string.h>

#define MAXLINELEN 1024

struct passPolicy
{
	int min, max;
	char c;
};

int nbad = 0;

int
validatePass(struct passPolicy pp, char *pass)
{
	int occ = 0;
	while (*pass != 0) {
		if (pp.c == *pass)
			occ++;
		pass++;
	}
	return occ >= pp.min && occ <= pp.max;
}

void
doLine(char *in)
{
	int min = 0, max = 0;
	char c;
	struct passPolicy pp;
	char *pass;
	sscanf(strtok(in, ":"), "%d-%d %c", &min, &max, &c);
	pp.min = min;
	pp.max = max;
	pp.c = c;
	pass = strtok(NULL, ":");
	if (!validatePass(pp, pass))
		nbad++;
}

int
doFile(char *fname, void (*f)(char *s))
{
	FILE *fd;
	int sum = 0;
	char line[MAXLINELEN];
	fd = fopen(fname, "r");
	assert(fd != NULL);
	while (fgets(line, MAXLINELEN, fd) != NULL) {
		(*f) (line);
		sum++;
	}
	fclose(fd);
	return sum;
}

int
main(int argc, char *argv[])
{
	int nelem = 0;
	nelem = doFile(argv[1], &doLine);
	printf("good passes:%d bad passes:%d\n", nelem - nbad, nbad);
	return 0;
}
