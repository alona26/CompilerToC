#include <stdio.h>
#include <stdlib.h>


static int* result;
static int result_size;

 int dot_product(int* v,int n1, int* u, int n2){ 
	int i; 
	int n=0; 
	int resultt = 0; 
	if (n1<n2){
	 n = n1;
	}
	else {
	n = n2;
	}
	for (i = 0; i < n; i++) {
		 resultt += v[i]*u[i]; 
	}
	return resultt;
}


void ops_function(int *v, int size_v, int *u, int size_u, char c){ 

result_size = size_v;
result = (int *) malloc( (result_size) * sizeof(int));

for(int i=0;i<result_size;i++){
	if (c == '+'){

if(i > size_u){
result[i] = v[i] + 0;
}
	else{

result[i] = v[i] + u[i];
}

}
	if (c == '-'){

if(i > size_u){
result[i] = v[i] - 0;
}
	else{

result[i] = v[i] - u[i];
}

}
	if (c == '*'){

if(i > size_u){
result[i] = v[i] * 0;
}
	else{

result[i] = v[i] * u[i];
}

}
	if (c == '/'){

if(i > size_u){		fprintf(stderr," ---Cannot be divided by 0---\n");

}
		if (u[i] == 0){
		fprintf(stderr," ---Cannot be divided by 0---\n");

}
		else{
		 result[i] = v[i] / u[i]; 
		}

}

}

}


void main(void) 
{
int i , fAvg ;
int size_fib  = 0;
int* fib ;
if (size_fib == 0){ 
 fib = (int *) malloc((0+1) * sizeof(int));
 size_fib += 1; 
}

if (0 > size_fib - 1){ 
 fib = (int *) realloc(fib, (1) * sizeof(int));
 size_fib += 1; 
}

fib[0] = 0 ; 

if (size_fib == 0){ 
 fib = (int *) malloc((1+1) * sizeof(int));
 size_fib += 1; 
}

if (1 > size_fib - 1){ 
 fib = (int *) realloc(fib, (1) * sizeof(int));
 size_fib += 1; 
}

fib[1] = 1 ; 
i = 2 ;
printf("%d, %d \n",0 , 0 );
printf("%d, %d \n",1 , 1 );
while (i < 16){

if (size_fib == 0){ 
 fib = (int *) malloc((i+1) * sizeof(int));
 size_fib += 1; 
}

if (i > size_fib - 1){ 
 fib = (int *) realloc(fib, (1) * sizeof(int));
 size_fib += 1; 
}

fib[i] = fib[(i-2)] + fib[(i-1)] ; 
printf("%d, %d \n",i , fib[i] );
i = i + 1 ;
}
printf("%d\n",dot_product(fib,size_fib,(int []){1 , 1 , 1 , 1 , 1 , 1 , 1 , 1 , 1 , 1 , 1 , 1 , 1 , 1 , 1 , 1 },16) );
fAvg = dot_product(fib,size_fib,(int []){1 , 1 , 1 , 1 , 1 , 1 , 1 , 1 , 1 , 1 , 1 , 1 , 1 , 1 , 1 , 1 },16) / 16 ;
printf("%d\n",fAvg );
i = 2 ;
while (i < 16){
if (fib[i] > fAvg){
printf("%d, %d \n",i , fib[i] );
}
i = i + 1 ;
}
}
