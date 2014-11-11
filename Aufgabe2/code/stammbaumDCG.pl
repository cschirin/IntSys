% prolog stammbaumDCG.pl
% IS Praktikum 2
% Timo Lange, Christian Schirin
% 29.Oktober.2014

/* einstiegspunkt für die dcg-anwendung.
   beim aufrufen kann man eine frage stellen, welche
   am besten mit ? aber auch möglich mit ! oder . abgeschlossen
   wird. */
:- consult('../beispielcode/readsentence.pl').
:- consult('DCGCode.pl').
frage_stellen :- read_sentence(FrageListe),
	filtere_satzzeichen(FrageListe,GefilterteListe),
	s(Sem,FrageTyp,GefilterteListe,[]), write(Sem), nl,
	antworten(Sem,AntwortSatz,FrageTyp),
        append(AntwortSatz,['.'],AntwortSatzMitPunkt),
	schreibe_satz(AntwortSatzMitPunkt),nl.


%% filtere_satzzeichen(+Mit,-Ohne)
%% hilfsfunktion um nicht DCG mit verarbeitung von Satzzeichen belasten
%% zu müssen.
filtere_satzzeichen([],[]).
filtere_satzzeichen([Word|List],[Word|Gefiltert]) :- Word \== '.', Word \== '!', Word \== '?',
	filtere_satzzeichen(List,Gefiltert).
filtere_satzzeichen([_Word|List],Gefiltert) :- filtere_satzzeichen(List,Gefiltert).



%% antworten(+Frage,+FrageP, -Antwort,+Fragetyp)
%% gibt eine antwort für eine als liste von atomen gegebene Fragesatz.
%% Es werden Entscheidungsfragen und Ergänzungsfragen über den stammbaum aus
%% Aufgabe 1 beantwortet.
%% Parameter:
%% Frage - Ein satz als liste von atomen
%% FrageP - Die semantik des satzes aus dem parameter darüber
%% Antwort - Ein satz als liste von atomen
%% Fragetyp - Atom - wahl zwischen 'ergaenzungsfrage' und
%% 'entscheidungsfrage'
antworten(FrageP,Antwort,ergaenzungsfrage) :-
	/* Ergaenzungsfragen haben die struktur "Wer ist der <Beziehung> von Y?"
	  Antworten darauf lassen sich mit der Struktur  "X ist der <Beziehung> von Y"
	  formulieren. */
	  FrageP, %% Frage an stammbaum stellen
          FrageP =.. [Beziehung,P1,P2],
          artikel_aus_eigenname(AP1,P1), 
          Antwort = [P1,ist,AP1,Beziehung,von,P2].

%!  artikel_aus_eigenname(+Artikel:atom,-Eigenname:atom) is det 
%   hilfsfunktion, um zu einem eigennamen den entsprechenden artikel zu finden.
artikel_aus_eigenname(der,EigennameMaennlich) :- mann(EigennameMaennlich).
artikel_aus_eigenname(die,EigennameWeiblich) :- frau(EigennameWeiblich).

/*Entscheidungsfragen sind Ja-Nein Fragen
	und lassen sich daher mit "Ja" und "Nein" beantworten.*/
antworten(FrageP,['Ja'],entscheidungsfrage) :- FrageP.
antworten(FrageP,['Nein'],entscheidungsfrage) :- not(FrageP).
	



%% schreibe_satz(+Satz)
%% Gibt einen satz auf der konsole aus
%% Parameter: Satz - eine liste von atomen
schreibe_satz([]). %Rekursionsabbruch
schreibe_satz([Word|Rest]) :- write(Word),tab(1),schreibe_satz(Rest). %tab macht leerzeichen 



%Unit-tests

:- begin_tests(stammbaumDCG).

test(antworten) :-
    antworten(
    vater(klaus,siegfried),
    ['Ja'],
    entscheidungsfrage
    ).
test(antworten) :-
    antworten(
    mutter(maria,michael),
    ['Nein'],
    entscheidungsfrage
    ).
test(antworten) :-
    antworten(
    vater(_,siegfried),
    [klaus,ist,der,vater,von,siegfried],
    ergaenzungsfrage
    ).
test(antworten) :-
    antworten(
    onkel(_,simone),
    [karl,ist,der,onkel,von,simone],
    ergaenzungsfrage
    ).
test(antworten) :-
    antworten(
    tante(_,simone),
    [anna,ist,die,tante,von,simone],
    ergaenzungsfrage
    ).
:- end_tests(stammbaumDCG).


