:- encoding(utf8).
% ist1117729 Duarte Veríssimo
:- style_check(-discontiguous).
:- set_prolog_flag(answer_write_options, [max_depth(0)]).

:- ['codigoAuxiliar.pl'].
:- ['bd_estudantes.pl'].
:- ['listas_palavras.pl'].

% O teu código começa aqui


media([], 0).
media(ListaValores , Media):-
    sum_list(ListaValores, Soma),
    length(ListaValores, Num),
    M is Soma / Num,
    arredonda(M, Media).

mediaNotasPorIdade(IdadeMin, IdadeMax, Media) :-
    findall(Nota, (estudante(Id, Idade, _), Idade > IdadeMin, Idade =< IdadeMax, exame(Id, Nota)), ListaNotas),
    media(ListaNotas, Media).


freqPorGenero(Genero, MediaFreq) :-
    findall(Freq, (estudante(Id, _, Genero), atividade(Id,_ ,_, Freq )), ListaFreq),
    media(ListaFreq, MediaFreq).

alertaSaude(HorasSono, Exercicio, SaudeMental, ListaAlunos) :-
    findall(Id, (estudante(Id, _, _), 
    saude(Id, HorasSono1, fraca, Exercicio1, SaudeMental1),
    HorasSono1 < HorasSono, 
    Exercicio1 < Exercicio, 
    SaudeMental1 < SaudeMental), Lista),
    sort(Lista, ListaAlunos).

