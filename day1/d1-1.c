#include <stdio.h>
#include <assert.h>

#define MAXELEMS (200)
#define TARGET 2020

int		elems      [MAXELEMS] = {0};	/* each of the numbers */
int		diffelem   [TARGET] = {0};	/* index + value = target ,
						 * or val = 0 */

int
readfile(char *fname)
{
	FILE           *fp;
	int		i = 0,	num = 0;
	fp = fopen(fname, "r");
	assert(fp != NULL);

	while (fscanf(fp, "%d", &num) != EOF) {
		elems[i++] = num;
		diffelem[TARGET - num] = num;
	}
	fclose(fp);
	return i;
}

int
main(int argc, char *argv[])
{
	int		nelems    , i, c1, c2;
	nelems = readfile(argv[1]);
	printf("i read %d elems\n", nelems);
	for (i = 0; i < nelems; i++) {
		if (diffelem[elems[i]] != 0) {
			c1 = elems[i];
			c2 = diffelem[c1];
			printf("pair: %d and %d with product:%d\n", c1, c2, c1 * c2);
			break;
		}
	}

	return 0;
}
