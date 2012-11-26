#include <stdio.h>
#include <stdlib.h>
#include <math.h>

double *fft(const double *in_data, const int size);
/*double *fft(const double *in_data, const int size)
{
	int i;
	
	int k = 0;
	while ((1 << k) < size)
		k++;

	int *rev = (int*) calloc(size, sizeof(int));
	rev[0] = 0;
	int high1 = -1;
	for (i = 1; i < size; ++i)
	{
		if ((i & (i - 1)) == 0)		
			high1++;
		
		rev[i] = rev[i ^ (1 << high1)];
		rev[i] |= (1 << (k - high1 - 1));
	}

	double *roots = (double*) calloc(2 * size, sizeof(double));
	double alpha = 2 * M_PI / size;
	for (i = 0; i < size; ++i)
	{
		roots[2 * i] = cos(i * alpha);
		roots[2 * i + 1] = sin(i * alpha);
	}

	double *cur = (double*) calloc(2 * size, sizeof(double));
	for (i = 0; i < size; ++i)
	{
		int ni = rev[i];
				
		cur[2 * i] = in_data[2 * ni];
		cur[2 * i + 1] = in_data[2 * ni + 1];
	}
	free(rev);

	int len;
	for (len = 1; len < size; len <<= 1)
	{
		double *ncur = (double*) calloc(2 * size, sizeof(double));
		
		int rstep = size / (2 * len);
		int pdest;
		for (pdest = 0; pdest < size; )
		{
			int p1 = pdest;
						
			for (i = 0; i < len; ++i)
			{
				double val_r = roots[2 * (i * rstep)] * cur[2 * (p1 + len)] - roots[2 * (i * rstep) + 1] * cur[2 * (p1 + len) + 1];
				double val_i = roots[2 * (i * rstep)] * cur[2 * (p1 + len) + 1] + roots[2 * (i * rstep) + 1] * cur[2 * (p1 + len)];
				
				ncur[2 * pdest] = cur[2 * p1] + val_r;
				ncur[2 * pdest + 1] = cur[2 * p1 + 1] + val_i;
				ncur[2 * (pdest + len)] = cur[2 * p1] - val_r;
				ncur[2 * (pdest + len) + 1] = cur[2 * p1 + 1] - val_i;
				
				pdest++, p1++;
			}
			
			pdest += len;
		}
		
		double *tmp = ncur;
		ncur = cur;
		cur = tmp;

		free(ncur);
	}	
	free(roots);
	
	return cur;
}*/

int main(int argc, char* argv[])
{
	FILE *in = fopen("fft.in", "r");

	if (in == 0)
	{
		fprintf(stderr, "cannot open file 'fft.in'\n");
		return 1;
	}

	int size, i;
	fscanf(in, "%d", &size);
	double *in_data = (double*) calloc(2 * size, sizeof(double));

	for (i = 0; i < 2 * size; ++i)	
		fscanf(in, "%lF + %lFi", &in_data[2 * i], &in_data[2 * i + 1]);

	double *out_data = (double*) calloc(2 * size, sizeof(double));
	out_data = fft(in_data, size);

	fclose(in);
	free(in_data);

	FILE *out = fopen("fft.out", "w");

	for (i = 0; i < size; ++i)
		fprintf(out, "%lF + %lFi\n", out_data[2 * i], out_data[2 * i + 1]);	

	fclose(out);
	free(out_data);

	return 0;
}
