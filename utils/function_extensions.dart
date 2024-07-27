
RT Function(T3) apply2<RT, T1, T2, T3>(RT Function(T1, T2, T3) f, T1 t1, T2 t2) {
    RT applied(T3 t3) => f(t1, t2, t3);
    return applied;
}

RT Function(T2) apply1<RT, T1, T2>(RT Function(T1, T2) f, T1 t1) {
    RT applied(T2 t2) => f(t1, t2);
    return applied;
}