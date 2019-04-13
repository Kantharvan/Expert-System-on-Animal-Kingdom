


%write on  the group
group_write(S,N):-
    S = s(_,V,AP),
    addItem(N,AP).

% multiple statements, break down...
processStatement(Conditions,N):-
    link(_,[Link],[]),
    Conditions = condition(S,Link,Rest),
    assignN(S,N),
    append('knowledge/knowledge.pl'),
    writeStatement(S,N), nl,tab(10),
    write(Link), write(' '), nl,tab(5),
    processStatement(Rest,N).    
    
% one condition consisting of one sentence
processStatement(Condition,N):-
    Condition = condition(S),
    assignN(S,N),
    append('knowledge/knowledge.pl'),
    writeStatement(S,N).

% one sentence
processStatement(S,N):-
    append('knowledge/knowledge.pl'),
    writeStatement1(S,N).

% if the rule has no object yet take the n from the first 
% sentence and define that as the object, otherwise leave
% it alone.
assignN(From,Old):-
    \+ atom(Old),
    From = s(Old,_,_).
assignN(_,_).

% a statement a la 'X isa good flier'
writeStatement(S,N):-
    S = s(_,V,AP),
    ensureList(AP,Neu),
    atom_concat('Var_',N,N1),
    append('knowledge/knowledge.pl'),
    append([N1],[V],VarV), 
    writeList(VarV),
    write(' '), % ... 'good flier'
    write('\''), writeList(Neu), write('\''), 
    write(' '),!.

% a statement a la 'X isa good flier'
writeStatement1(S,N):-
    S = s(_,V,AP),

    ensureList(AP,Neu),
    atom_concat('Var_',N,N1),
    append('knowledge/knowledge.pl'),
    append([N1],[V],VarV), 
    writeList(VarV),
    write(' '), % ... 'good flier'
    write('\''), writeList(Neu), write('\''), 
    write(' '),!.

% ------------------------------------
% helpers for entering facts
% ------------------------------------

% print existing rules
readAllClauses(X):-
    at_end_of_stream(X),
    close(X),nl.
readAllClauses(X):-
    read_clause(X,Result),
    write(Result),nl,
    readAllClauses(X).

% create a file for each new group
createFileWithDynDecl(Name):-
    % create new file for group, incl dynamic declaration:
    atom_concat('knowledge/groups/',Name,X),
    atom_concat(X,'.pl',File),
    %write('appending to: '),write(File),nl,
    append(File),
    atom_concat(':- dynamic(',Name,Buff),
    atom_concat(Buff,'/1).',DynDec),
    write(DynDec),
    told.


addItem(Item,Group):-

    atom_concat('knowledge/groups/',Group,X),
    atom_concat(X,'.pl',File),
    (exists_file(File)->
        write('file exists'),
        write('appending to: '),write(File),nl;
        write('no such file'),
        process([create,group,Group,'.'])
    ),
    
    append(File),
    Predicate =.. [Group,Item],
    assert(Predicate),
    nl, write(Predicate),
    write('.'),nl,
    told,
    
    write('ok, added item: '), write(Item),
    write(' to group: '), write(Group), nl. 


    
        



% ------------------------------------
% helpers for queries
% ------------------------------------

% to query "is the moon a planet?"---- > moon isa planet
removeDet(X,Result):-
    X=[Result]. 
removeDet(X,Result):-
    X=[_,Result].

ensureAtom(Test,Result):-
    atom(Test),
    Result = Test.
ensureAtom(Test,Result):-
    listToAtom(Test,_,Result).

% [green,greasy,hair] ---- > 'green greasy hair'
listToAtom([],_,_).
% last element:
listToAtom([H|[]],Atom,Result):-
    atom(Atom),
    atom_concat(Atom,' ',AtomB),
    atom_concat(AtomB,H,Atom2),
    Result = Atom2.
% in between:
listToAtom([H|T],Atom,Result):-
    atom(Atom),
    atom_concat(Atom,' ',AtomB),
    atom_concat(AtomB,H,Atom2),
    listToAtom(T,Atom2,Result).
% first element:
listToAtom([H|T],_,Result):-
    H = Atom,
    listToAtom(T,Atom,Result).

% before calling writeList
ensureList(X,Neu):-
    is_list(X),
    Neu = X.
ensureList(X,Neu):-
    \+ is_list(X),
    Neu = [X].
    
% add blanks between a elements but the last
writeList([]).
writeList([H|T]):-
    write(H), 
    T \= [],
    write(' '),
    writeList(T).
writeList([_|T]):-
    T = [],
    writeList(T).




