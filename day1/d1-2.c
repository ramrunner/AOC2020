#include <stdio.h>
#include <assert.h>

#define MAXELEMS (200)
#define TARGET 2020

struct pair {
	int		a;
	int		b;
};

int		elems      [MAXELEMS] = {0};	/* each of the numbers */
struct pair	diffelem[TARGET] = {{0, 0}};	/* index is the diff of 
						 * the sum of pair from target and
						 * val is the pair of nums */

int
readfile(char *fname)
{
	FILE           *fp;
	int		i, num;
	fp = fopen(fname, "r");
	assert(fp != NULL);

	while (fscanf(fp, "%d", &num) != EOF) {
		elems[i++] = num;
	}
	fclose(fp);
	return i;
}

int
main(int argc, char *argv[])
{
	int		nelems    , i, j, c1, c2, c3;
	nelems = readfile(argv[1]);
	printf("i read %d elems\n", nelems);
	for (i = 0; i < nelems; i++) {
		c1 = elems[i];
		for (j = 0; j < nelems; j++) {
			c2 = elems[j];
			if ((c1 + c2) <= TARGET) {
				diffelem[TARGET - c1 - c2].a = c1;
				diffelem[TARGET - c1 - c2].b = c2;
			}
		}
	}

	for (i = 0; i < nelems; i++) {
		c1 = elems[i];
		if (diffelem[c1].a != 0 && diffelem[c1].b != 0) {
			c2 = diffelem[c1].a;
			c3 = diffelem[c1].b;
			printf("triple: %d %d %d with product:%d\n", c1, c2, c3, c1 * c2 * c3);
			break;
		}
	}

	return 0;
}
