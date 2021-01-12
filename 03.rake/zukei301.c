/***************************/
/*  三角形を表示する（１） */
/***************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

char  buf[25][80];                       // 25x80文字分の配列

void  Gen_line(int,int,int,int);         // 線分生成


int  main( )
{
    int     x1= 5,y1= 0;                 // 頂点1
    int     x2=25,y2= 0;                 // 頂点2
    int     x3=30,y3=10;                 // 頂点3
    int     y;

    memset(&buf[0][0],' ',25*80);        // 配列を空白で初期化

    //--線分プロット--
    Gen_line(x1,y1,x2,y2);               // 線分生成
    Gen_line(x2,y2,x3,y3);               // 線分生成
    Gen_line(x3,y3,x1,y1);               // 線分生成

	//--表示--
    for( y=24; y>=0; y-- )
      { printf("%.80s",&buf[y][0]); }   // 画面１行表示
    fflush(stdout);
}


void  Gen_line(
/*------------*/
/*  線分生成  */
/*------------*/
int  xS,  // 始点
int  yS,
int  xE,  // 終点
int  yE)
{
    double  dx,dy,a=0,b=0;
    int     x,y;

    buf[yS][xS]='*';                                    // 始点
    buf[yE][xE]='*';                                    // 終点

    if ( xS==xE )                                       // 垂直線
      {
        if ( yS>yE ) { y=yS; yS=yE; yE=y; }
        for( y=yS+1; y<yE; y++ ) buf[y][xS]='*';        // 線分上の点
      }
    else
      {
        if ( xS>xE )
          { x=xS; xS=xE; xE=x; y=yS; yS=yE; yE=y; }     // 始点終点入れ替え

        dx=xE-xS; dy=yE-yS;
        a=dy/dx; b=yS-a*xS;                             // 直線の係数

        for( x=xS+1; x<xE; x++ )                        // 線分補完
          {
            y=a*x+b+0.5;                                // 計算結果は四捨五入
            buf[y][x]='*';
          }
      }
}
