#include<iostream>
using namespace std;
int main(){
	int n , m1=0, m2=0;
	cin >> n;
	for(;n--;){
		int k;
		cin >> k;
		if(k>=m1){
			m2=m1;
			m1=k;
		}
		else if(k>m2)
			m2=k;
	}
	cout << (m1+m2) << endl ;
	return 0;
}
