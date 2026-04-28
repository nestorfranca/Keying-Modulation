import numpy as np

Fs = 97656.25
Q = 14
scale = 1 << Q
frequencias = [1000, 10000]

for f in frequencias:
    w = 2 * np.pi * f / Fs
    coef = int(round(2 * np.cos(w) * scale))
    yn1  = int(round(np.cos(0) * scale))
    yn2  = int(round(np.cos(w) * scale))
    f_real = np.arccos(coef / (2 * scale)) * Fs / (2 * np.pi)
    print(f"f = {f} Hz → COEF = {coef}, YN1 = {yn1}, YN2 = {yn2}, f_real = {f_real:.2f} Hz")