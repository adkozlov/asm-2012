#include <stdio.h>
#include <stdlib.h>
#include <math.h>

extern double *fft(const double *in_data, const int size);
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
		int p1;
		for (p1 = 0; p1 < size; p1 += len)
		{
			for (i = 0; i < len; ++i)
			{
				double val_r = roots[2 * (i * rstep)] * cur[2 * (p1 + len)] - roots[2 * (i * rstep) + 1] * cur[2 * (p1 + len) + 1];
				double val_i = roots[2 * (i * rstep)] * cur[2 * (p1 + len) + 1] + roots[2 * (i * rstep) + 1] * cur[2 * (p1 + len)];
				
				ncur[2 * p1] = cur[2 * p1] + val_r;
				ncur[2 * p1 + 1] = cur[2 * p1 + 1] + val_i;
				ncur[2 * (p1 + len)] = cur[2 * p1] - val_r;
				ncur[2 * (p1 + len) + 1] = cur[2 * p1 + 1] - val_i;
				
				p1++;
			}
		}
		
		double *tmp = ncur;
		ncur = cur;
		cur = tmp;

		free(ncur);
	}	
	free(roots);
	
	return cur;
}*/

extern double *fft_rev(const double *in_data, const int size);
/*double *fft_rev(const double *in_data, const int size)
{
	double *cur = fft(in_data, size);
	
	int i;
	double size_d = (double) size;
	for (i = 0; i < 2 * size; ++i)
		cur[i] /= size_d;		
	
	for (i = 1; i < size / 2; ++i)
	{
		double val_r = cur[2 * i];
		double val_i = cur[2 * i + 1];		
		int i_rev = size - i;
		
		cur[2 * i] = cur[2 * i_rev];
		cur[2 * i + 1] = cur[2 * i_rev + 1];
		
		cur[2 * i_rev] = val_r;
		cur[2 * i_rev + 1] = val_i;
	}
	
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

	fclose(in);

	double *out_data = (double*) calloc(2 * size, sizeof(double));
	out_data = fft(in_data, size);
	in_data = fft_rev(out_data, size);
	

	FILE *out = fopen("fft.out", "w");

	fprintf(out, "direct:\n");
	for (i = 0; i < size; ++i)
		fprintf(out, "%lF + %lFi\n", out_data[2 * i], out_data[2 * i + 1]);
		
	fprintf(out, "\nreverse:\n");
	for (i = 0; i < size; i++)
		fprintf(out, "%lF + %lFi\n", in_data[2 * i], in_data[2 * i + 1]);		

	fclose(out);

	free(in_data);
	free(out_data);

	return 0;
}
