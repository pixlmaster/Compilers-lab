//
/* test..ugh
*/
int test = 5;
double d = 2.3;
int i, w[10];
int a = 4, *p, b;
void func(int i, double d);
char c;
int main () {
	a = 10;
	int *x, y;
	x = &y;
	*x = y;
	y = *x;
	int a=1, b=2, c;
	c = a + b;
	a++;
	int check = a+b*c;
	if (check < c) 
		c = a|b;
	i = ++a;
	int n = 6;
	int fn = (int)d;
	fn = factorial(n);
	int i, a[10], v = 5;
	double d1 = 123.456;
	double d = f1(d1);
	char* ex1 = "halo";
	char* ex2 = f2(ex1);
	/*dfgh d
	s*/
	for (i=1; i<a[10]; i++) 
		i++;
	do i = i - 1; while (a[i] < v);
	i = 2;
	if (i&&v) i = 1;
	int ar1[] = {1,2,4};
	return 0;
}

double f1(double i){
	double x=12.31;/**/
double y = 32.54;
/*
*/
	double z = x*i/y;
	return z; //x*i/y;
}
/*
*/
char* f2(const char* ci){
	return ci;
}
int factorial (int n) {
	int m = n-1;
	int r = 1;
	if (m) {
		int fn = factorial(m-1);
		r = n*fn;
	}
	return r;
}
int add (int a, int b) {
	a = 10;
	int *x, y;
	x = &y;
	*x = y;
	y = *x;
}
