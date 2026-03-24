main :-
    cargar_datos(Estudiantes),
    menu(Estudiantes).

cargar_datos(Estudiantes) :-
    open('UniversityPL.txt', read, Stream),
    read(Stream, Estudiantes),
    close(Stream).

guardar_datos(Estudiantes) :-
    open('UniversityPL.txt', write, Stream),
    write(Stream, Estudiantes),
    write(Stream, '.'),
    close(Stream).

menu(Estudiantes) :-
    nl, write('--- SISTEMA DE REGISTRO UNIVERSIDAD ---'), nl,
    write('1) Check In'), nl,
    write('2) Buscar por ID'), nl,
    write('3) Calculo de Tiempo'), nl,
    write('4) Listar Estudiantes'), nl,
    write('5) Check Out'), nl,
    write('0) Salir'), nl,
    write('Elige una opcion (termina con punto): '), nl,
    read(Opcion),
    procesar_opcion(Opcion, Estudiantes).

procesar_opcion(1, Estudiantes) :-
    nl, write('Ingrese ID del estudiante (con comillas simples, ej. ''1001''.): '), nl,
    read(ID),
    ( number(ID) ->
        write('-> Error: El ID debe ingresarse como texto (entre comillas simples).'), nl,
        menu(Estudiantes)
    ;
        ( buscar_estudiante(ID, Estudiantes, _) ->
            write('-> Error: El estudiante ya se encuentra registrado.'), nl,
            menu(Estudiantes)
        ;
            write('Ingrese hora de entrada (minutos desde 00:00, solo enteros, ej. 480.): '), nl,
            read(Hora),
            ( integer(Hora) ->
                NuevoEstudiante = estudiante(ID, Hora),
                NuevosEstudiantes = [NuevoEstudiante | Estudiantes],
                guardar_datos(NuevosEstudiantes),
                write('-> Estudiante registrado exitosamente.'), nl,
                menu(NuevosEstudiantes)
            ;
                write('-> Error: La hora de entrada debe ser un numero entero.'), nl,
                menu(Estudiantes)
            )
        )
    ).

procesar_opcion(2, Estudiantes) :-
    nl, write('Ingrese ID a buscar (ej. ''1001''.): '), nl,
    read(ID),
    ( buscar_estudiante(ID, Estudiantes, Hora) ->
        write('-> Estudiante encontrado. Entro a los '), write(Hora), write(' minutos.'), nl
    ;
        write('-> Estudiante no encontrado o ya salio.'), nl
    ),
    menu(Estudiantes).

procesar_opcion(3, Estudiantes) :-
    nl, write('Ingrese ID del estudiante (ej. ''1001''.): '), nl,
    read(ID),
    ( buscar_estudiante(ID, Estudiantes, HEntrada) ->
        write('Ingrese hora actual (minutos desde 00:00, ej. 540.): '), nl,
        read(HSalida),
        ( integer(HSalida), HSalida >= HEntrada ->
            Duracion is HSalida - HEntrada,
            Horas is Duracion // 60,
            Minutos is Duracion mod 60,
            write('-> Tiempo de permanencia: '), write(Horas), write(' horas y '), write(Minutos), write(' minutos.'), nl
        ;
            write('-> Error: La hora actual debe ser un numero entero y no puede ser anterior a la de entrada.'), nl
        )
    ;
        write('-> Estudiante no encontrado.'), nl
    ),
    menu(Estudiantes).

procesar_opcion(4, []) :-
    nl, write('--- Estudiantes Registrados ---'), nl,
    write('-> No hay ningun estudiante registrado en este momento.'), nl,
    menu([]).

procesar_opcion(4, Estudiantes) :-
    Estudiantes \= [],
    nl, write('--- Estudiantes Registrados ---'), nl,
    write(Estudiantes), nl,
    menu(Estudiantes).

procesar_opcion(5, Estudiantes) :-
    nl, write('Ingrese ID a dar salida (ej. ''1001''.): '), nl,
    read(ID),
    ( buscar_estudiante(ID, Estudiantes, HEntrada) ->
        write('Ingrese hora de salida (minutos desde 00:00, ej. 600.): '), nl,
        read(HSalida),
        ( integer(HSalida), HSalida >= HEntrada ->
            Duracion is HSalida - HEntrada,
            eliminar_estudiante(ID, Estudiantes, NuevosEstudiantes),
            guardar_datos(NuevosEstudiantes),
            write('-> Check Out exitoso. Tiempo total: '), write(Duracion), write(' minutos.'), nl,
            menu(NuevosEstudiantes)
        ;
            write('-> Error: La hora de salida debe ser un entero y no puede ser anterior a la de entrada.'), nl,
            menu(Estudiantes)
        )
    ;
        write('-> Estudiante no encontrado.'), nl,
        menu(Estudiantes)
    ).

procesar_opcion(0, _) :-
    nl, write('Saliendo del sistema...'), nl.

procesar_opcion(_, Estudiantes) :-
    nl, write('Opcion invalida. Intenta de nuevo.'), nl,
    menu(Estudiantes).

buscar_estudiante(ID, [estudiante(ID, Hora) | _], Hora).
buscar_estudiante(ID, [estudiante(OtroID, _) | Cola], Hora) :-
    ID \= OtroID,
    buscar_estudiante(ID, Cola, Hora).

eliminar_estudiante(_, [], []).
eliminar_estudiante(ID, [estudiante(ID, _) | Cola], Cola).
eliminar_estudiante(ID, [estudiante(OtroID, Hora) | Cola], [estudiante(OtroID, Hora) | NuevaCola]) :-
    ID \= OtroID,
    eliminar_estudiante(ID, Cola, NuevaCola).