:- encoding(utf8).
% ist1117729 Duarte Veríssimo
:- style_check(-discontiguous).
:- set_prolog_flag(answer_write_options, [max_depth(0)]).

:- ['codigoAuxiliar.pl'].
:- ['bd_estudantes.pl'].
:- ['listas_palavras.pl'].



%------------------------------------------------------------------------------------------------------------------------------------------
% Parte 1

media([], 0):-!.
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
somaQuadrados([H|T], Resultado):-
    somaQuadrados(T, Soma),
    H1 is H*H,
    Resultado is Soma + H1.

produtoEscalar([],[],0).
produtoEscalar([H1|T1], [H2|T2], Resultado) :-
    produtoEscalar(T1, T2, Ac),
    Soma is H1*H2,
    Resultado is Ac + Soma.

correlacao(Lista1, Lista2, Resultado):-
    media(Lista1, Media1),
    media(Lista2, Media2),
    subtraiValorDeLista(Lista1, Media1, L1),
    subtraiValorDeLista(Lista2, Media2, L2),
    produtoEscalar(L1, L2, Numerador),
    somaQuadrados(L1, QuadradosL1),
    somaQuadrados(L2, QuadrdadosL2),
    RaizQuadradosL1 is sqrt(QuadradosL1),
    RaizQuadradosL2 is sqrt(QuadrdadosL2),
    Denominador is RaizQuadradosL1*RaizQuadradosL2,
    Denominador =\= 0,
    Resultado1 is Numerador / Denominador,
    arredonda(Resultado1, Resultado).

%------------------------------------------------------------------------------------------------------------------------------------------
% Parte 2

tamanho(Palavra, Tamanho):-
    string_chars(Palavra, P),
    length(P, Tamanho).

verificaECalcula(Palavra1, Palavra2, CaracteresPalavra1, CaracteresPalavra2):-
    tamanho(Palavra1, N),
    tamanho(Palavra2, N),
    string_chars(Palavra1, CaracteresPalavra1),
    string_chars(Palavra2, CaracteresPalavra2).

quantasN(Id, N, Quantas):-
    lista_palavras(Id, Lista),
    findall(Palavra, (member(Palavra, Lista), tamanho(Palavra, N)), ListaPalavrasTamanhoN),
    length(ListaPalavrasTamanhoN, Quantas).

quantasC(Id, C, Quantas):-
    lista_palavras(Id, Lista),
    findall(Palavra, (member(Palavra, Lista), string_chars(Palavra, ListaP), ListaP = [C|_] ), ListaPalavrasCaracterC),
    length(ListaPalavrasCaracterC, Quantas).

apagaElemento(_, [], []) :- !.
apagaElemento(Elemento, [Elemento|T], T) :- !.
apagaElemento(Elemento, [H|T], [H|Resto]) :-
    apagaElemento(Elemento, T, Resto).

posicoesPalavra(Palavra, Posicoes):-
    string_chars(Palavra, ListaP),
    posicoesPalavraAux(ListaP, 1, ListaPares),
    sort(ListaPares, Posicoes).

posicoesPalavraAux([], _, []).
posicoesPalavraAux([H|T], PosInicial, [Par|RestoListaPares]) :-
    Par = (H, PosInicial),
    PosAtual is PosInicial + 1,
    posicoesPalavraAux(T, PosAtual, RestoListaPares).

pista1(Palavra1, Palavra2, Pista):-
    tamanho(Palavra1, N1),
    tamanho(Palavra2, N2),
    N1 = N2,
    string_chars(Palavra1, ListaPalavra1),
    string_chars(Palavra2, ListaPalavra2),
    pista1AUX(ListaPalavra1, ListaPalavra2, Pista).

pista1AUX([], [], []).
pista1AUX([H1|T1], [H2|T2], [N|Resto]):-
    (H1 = H2 -> N = 2
    ;
    N = 0),
    pista1AUX(T1, T2, Resto).

pista2(Palavra1, Palavra2, Pista):-
    tamanho(Palavra1, N1),
    tamanho(Palavra2, N2),
    N1 = N2,
    string_chars(Palavra1, ListaPalavra1),
    string_chars(Palavra2, ListaPalavra2),
    pista2AUX(ListaPalavra1, ListaPalavra2, ListaPalavra1, Pista).

pista2AUX([],[], _, []).
pista2AUX([H1|T1], [H2|T2], ListaPalavra1, [N|Resto]):-
    (
        H1 = H2 -> N = 2
    ;
        member(H2, ListaPalavra1) -> N = 1
    ;
        N = 0
    ),
    pista2AUX(T1, T2, ListaPalavra1, Resto).

pista3(Palavra1, Palavra2, Pista):-
    tamanho(Palavra1, N1),
    tamanho(Palavra2, N2),
    N1 = N2,
    string_chars(Palavra1, ListaPalavra1),
    string_chars(Palavra2, ListaPalavra2),
    letrasDiferentes(ListaPalavra1, ListaPalavra2, ListaLetrasDiferentes),
    pista3AUX(ListaPalavra1, ListaPalavra2, ListaLetrasDiferentes, Pista).

letrasDiferentes([], [], []).
letrasDiferentes([H1|T1], [H2|T2], ListaFinal):-
    ( H1 \= H2 -> 
        letrasDiferentes(T1, T2 , Resto),
        ListaFinal = [H1|Resto] 
    ;
        letrasDiferentes(T1, T2, ListaFinal)
    ).

pista3AUX([], [], _, []).
pista3AUX([H1|T1], [H2|T2], ListaLetrasDiferentes, [N|Resto]):-
    ( H1 = H2 -> 
        N = 2, 
        pista3AUX(T1, T2, ListaLetrasDiferentes, Resto)
    ;
    select(H2, ListaLetrasDiferentes, ListaLetrasDiferentesNova) ->
        N = 1, 
        pista3AUX(T1, T2, ListaLetrasDiferentesNova, Resto)
    ;
        N = 0,
        pista3AUX(T1, T2, ListaLetrasDiferentes, Resto)
    ).  

%------------------------------------------------------------------------------------------------------------------------------------------
% Parte 3

maratonaFilmes(ListaFilmes, ListaRestricoes, Programacao):-
    completaComEmpty(ListaFilmes, ListaCom7Filmes),
    findall(Programacao1,(permutation(ListaCom7Filmes, Programacao1), verificaRestricoes(ListaRestricoes,Programacao1)), ListaComRepetidos),
    sort(ListaComRepetidos, Programacao).

completaComEmpty(ListaFilmes, ListaFilmesFinal):-
    length(ListaFilmes, Nfilmes),
    NumEmpty is 7 - Nfilmes,
    length(ListaEmptys, NumEmpty),
    maplist(=(empty), ListaEmptys),
    append([ListaFilmes, ListaEmptys], ListaFilmesFinal).


verificaRestricoes([],_).

verificaRestricoes([terror(Filme) | RestoDasRestricoes], Programacao):-
    nth1(IndiceFilmeTerror, Programacao, Filme),
    member(IndiceFilmeTerror, [3,4,7]),
    verificaRestricoes(RestoDasRestricoes, Programacao).

verificaRestricoes([soPode(Filme, Sessao) | RestoDasRestricoes], Programacao):-
    nth1(Sessao, Programacao, Filme),
    verificaRestricoes(RestoDasRestricoes, Programacao).

verificaRestricoes([nunca(Filme, Sessao) | RestoDasRestricoes], Programacao):-
    nth1(IndiceFilme, Programacao, Filme),
    IndiceFilme \= Sessao,
    verificaRestricoes(RestoDasRestricoes, Programacao).

verificaRestricoes([seguido(Filme1, Filme2) | RestoDasRestricoes], Programacao):-
    nth1(IndiceFilme1, Programacao, Filme1),
    nth1(IndiceFilme2, Programacao, Filme2),
    IndiceFilme1 \= 4,
    1 is IndiceFilme2 - IndiceFilme1,
    verificaRestricoes(RestoDasRestricoes, Programacao).

verificaRestricoes([naoSeguido(Filme1, Filme2) | RestoDasRestricoes], Programacao):-
    nth1(IndiceFilme1, Programacao, Filme1),
    nth1(IndiceFilme2, Programacao, Filme2),
    (
        (ModuloDiferencaIndices is abs(IndiceFilme1 - IndiceFilme2), ModuloDiferencaIndices \= 1)
    ;
        ((IndiceFilme1 = 4, IndiceFilme2 = 5); (IndiceFilme1 = 5, IndiceFilme2 = 4))
    ),
    verificaRestricoes(RestoDasRestricoes, Programacao).

verificaRestricoes([antes(Filme1, Filme2) | RestoDasRestricoes], Programacao):-
    nth1(IndiceFilme1, Programacao, Filme1),
    nth1(IndiceFilme2, Programacao, Filme2),
    IndiceFilme1 < IndiceFilme2,
    verificaRestricoes(RestoDasRestricoes, Programacao).
