#include <assert.h>
#include <stdio.h>
#include <string.h>

#define MAXSZ 1024

struct dim {
	int r;
	int c;
};

/*
 * treats the row as a circular list, wrapping around. 
 * to support n > totlen it would have to take the mod.
 */
void
memmove_wrap(void *dst, void *src, size_t n, size_t totlen)
{
	char tmp[MAXSZ]={0};
	assert(n < MAXSZ && n < totlen && totlen < MAXSZ);
	memcpy(tmp, src, n);
	memmove(dst, src + n, totlen - n);
	memmove(dst + (totlen - n), tmp, n);
}

struct dim
readfile(char *fname, char inmap[MAXSZ][MAXSZ])
{
	FILE *fp;
	struct dim ret = {0};
	fp = fopen(fname, "r");
	while(fgets(inmap[ret.r], MAXSZ, fp) != NULL) {
		ret.c = strlen(inmap[ret.r]);
		/* remove newline if there */
		if (ret.c > 0 && inmap[ret.r][ret.c-1] == '\n') {
			inmap[ret.r][ret.c-1] = '\0';
			ret.c -= 1;
		}
		ret.r++;
	}
	fclose(fp);
	return ret;
}

void
shift_all_rows(char in[MAXSZ][MAXSZ], char out[MAXSZ][MAXSZ], struct dim din,  size_t n)
{
	int r=0;
	for (r=0; r<din.r; r++)
		memmove_wrap(out[r], in[r], n, din.c);
}

void
copymap(char dst[MAXSZ][MAXSZ], char src[MAXSZ][MAXSZ])
{
	int i = 0;
	for (i = 0; i<MAXSZ; i++)
		memmove(dst[i], src[i], MAXSZ);
}

void
clearmap(char dst[MAXSZ][MAXSZ])
{
	int i = 0;
	for(i = 0; i<MAXSZ; i++)
		bzero(dst[i], MAXSZ);
}

void
transpose(char in[MAXSZ][MAXSZ], struct dim din, char out[MAXSZ][MAXSZ], struct dim *dout)
{
	int r = 0, c=0;
	dout->r = din.c;
	dout->c = din.r;
	for (r=0; r<dout->r; r++)
		for (c = 0; c< dout->c; c++)
			out[r][c] = in[c][r];
}

void
printmap(char inmap[MAXSZ][MAXSZ], struct dim d)
{
	int r;
	for (r = 0; r < d.r; r++)
		printf("%s\n", inmap[r]);
}

void
travel(char inmap[MAXSZ][MAXSZ], struct dim din, int right, int down, int steps)
{
	char s1[MAXSZ][MAXSZ]={0}, s2[MAXSZ][MAXSZ]={0};
	struct dim dtrans;
	copymap(s1, inmap);
	int step = 0;
	int trees = 0;
	for (step = 0; step <steps; step++) {
		shift_all_rows(s1, s2, din, right);
		clearmap(s1);
		transpose(s2, din, s1, &dtrans);
		clearmap(s2);
		shift_all_rows(s1, s2, dtrans, down);
		clearmap(s1);
		transpose(s2, dtrans, s1, &din);
		if (s1[0][0] == '#') {
			printf("OUCH\n");
			trees++;
		}
	}
	printf("you hit a total of :%d trees\n", trees);
}

int
main(int argc, char *argv[])
{
	char inmap[MAXSZ][MAXSZ]={0}, outmap[MAXSZ][MAXSZ] = {0};
	struct dim md, tmd;
	md = readfile(argv[1], inmap);
	printf("read in a matrix of %d rows %d columns\n", md.r, md.c);
	travel(inmap, md, 1, 1, md.r-1);
	travel(inmap, md, 3, 1, md.r-1);
	travel(inmap, md, 5, 1, md.r-1);
	travel(inmap, md, 7, 1, md.r-1);
	/* travelling for r.c-1 / down steps */
	travel(inmap, md, 1, 2, (md.r-1)/2);
	return 0;
}
