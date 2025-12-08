:- encoding(utf8).
% ist1117729 Duarte Veríssimo
:- style_check(-discontiguous).
:- set_prolog_flag(answer_write_options, [max_depth(0)]).

:- ['codigoAuxiliar.pl'].
:- ['bd_estudantes.pl'].
:- ['listas_palavras.pl'].

% O teu código começa aqui
%------------------------------------------------------------------------------------------------------------------------------------------

media([], 0).
media(ListaValores , Media):-
    sum_list(ListaValores, Soma),
    length(ListaValores, Num),
    Media1 is Soma / Num,
    arredonda(Media1, Media).

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

probEcraNotasAltas(HorasEcra, Nota, Probabilidade) :-
    findall(Id, (estudante(Id, _, _), 
    exame(Id, Nota1), Nota1 > Nota, 
    atividade(Id, _, HorasEcra1, _), HorasEcra1 > HorasEcra),
    Lista1),
    length(Lista1, N1),
    findall(Id, (estudante(Id, _, _),
    atividade(Id, _, HorasEcra1, _), HorasEcra1 > HorasEcra),
    Lista2),
    length(Lista2, N2),
    (N2 > 0 -> Probabilidade1 is N1 / N2; Probabilidade1 = 0),
    arredonda(Probabilidade1, Probabilidade).

subtraiValorDeLista([], _, []).
subtraiValorDeLista([H|T], Valor, [H1|T1]) :- 
    H1 is H - Valor,
    subtraiValorDeLista(T, Valor, T1).

somaQuadrados([], 0).
somaQuadrados([H|T], Resultado)):-
    H1 is H*H,
    
