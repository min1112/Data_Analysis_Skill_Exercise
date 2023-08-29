# -*- coding: utf-8 -*-
"""RFM 실습.ipynb

Automatically generated by Colaboratory.

Original file is located at
    https://colab.research.google.com/drive/1Zs-1ctFp8U9yccZGIq1lvdhg7sseJfPc

패키지 불러오기
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

import sklearn
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split

"""깃헙에서 CSV 파일 불러오기"""

df = pd.read_csv('https://raw.githubusercontent.com/min1112/Data_Analysis_Skill_Exercise/main/Part3.ch03_RFM/rfm_mart.csv')
df

df.info()

"""로지스틱 회귀계수 구하기"""

X = df.drop(['mem_no', 'last_ord_dt','is_back'], axis=1)
y = df['is_back']

X_train, X_test, y_train, y_test = sklearn.model_selection.train_test_split(X,y)

model = LogisticRegression()
model.fit(X_train, y_train)

model.score(X_test, y_test)

coef = pd.DataFrame({'features':X.columns, 'coefficient':model.coef_[0]})
coef

coef.iloc[1,1]

"""백분위수(Percentile) 기반으로 RFM 점수 산출하기"""

a1, a2, a3 = np.percentile(df['recency'], [20,40,60])
a1, a2, a3

def percent(x) :
  if x <= a1 :
    return 4
  elif x > a1 and x <= a2 :
    return 3
  elif x > a2 and x < a3 :
    return 2
  elif x >= a3 :
    return 1

df['recency_score'] = df['recency'].apply(percent)*-coef.iloc[0,1]
df

b1, b2, b3 = np.percentile(df['frequency'], [10,50,80])
b1, b2, b3

def percent(x) :
  if x <= b1 :
    return 1
  elif x > b1 and x <= b2 :
    return 2
  elif x > b2 and x <= b3 :
    return 3
  elif x > b3 :
    return 4

df['frequency_score'] = df['frequency'].apply(percent)*coef.iloc[1,1]
df

c1, c2, c3 = np.percentile(df['monetary'], [20,40,80])
c1, c2, c3

def percent(x) :
  if x <= c1 :
    return 1
  elif x > c1 and x <= c2 :
    return 2
  elif x > c2 and x <= c3 :
    return 3
  elif x > c3 :
    return 4

df['monetary_score'] = df['monetary'].apply(percent)*coef.iloc[2,1]
df

df['total_score'] = df['recency_score'] + df['frequency_score'] + df['monetary_score']
df

"""총 점수로 5그룹 분류"""

t1, t2, t3, t4 = np.percentile(df['total_score'], [20,50,70,90])
t1, t2, t3, t4

def level(x) :
  if x <= t1 :
    return 5
  elif x > t1 and x <= t2 :
    return 4
  elif x > t2 and x <= t3 :
    return 3
  elif x > t3 and x <= t4 :
    return 2
  elif x > t4 :
    return 1

df['level'] = df['total_score'].apply(level)
df

df.level.value_counts()



"""5그룹별로 리텐션(1-리텐션) 구하기"""

pivot = df.groupby('level').agg({'is_back':'sum', 'mem_no':'count'})
pivot

pivot['retention'] = pivot.is_back/pivot.mem_no
pivot

