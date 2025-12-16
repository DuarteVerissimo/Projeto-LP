:- encoding(utf8).
% ist1117729 Duarte Veríssimo
:- style_check(-discontiguous).
:- set_prolog_flag(answer_write_options, [max_depth(0)]).

:- ['codigoAuxiliar.pl'].
:- ['bd_estudantes.pl'].
:- ['listas_palavras.pl'].



%------------------------------------------------------------------------------------------------------------------------------------------
% Parte 1
%------------------------------------------------------------------------------------------------------------------------------------------


% Calcula a média aritmética de uma lista de valores
% Caso Base: A média de uma lista vazia é 0 (o cut (!) impede que volte atrás) 
media([], 0):-!.
media(ListaValores , Media):-
    sum_list(ListaValores, Soma),
    length(ListaValores, Num),
    Media1 is Soma / Num,
    arredonda(Media1, Media).


% Calcula a média das notas dos exames de todos os estudantes de um certo
% intervalo de idades ([IdadeMin, IdadeMax])
mediaNotasPorIdade(IdadeMin, IdadeMax, Media) :-
    % Recolhe todas as notas de alunos que estao nesse intervalo de 
    % idades e junta numa lista
    findall(Nota, (
        estudante(Id, Idade, _), 
        Idade > IdadeMin, 
        Idade =< IdadeMax, 
        exame(Id, Nota)
    ), ListaNotas),
    media(ListaNotas, Media).       % Calcula a media dessa lista


% Calcula a media da frequência de atividade física de todos os estudantes 
% de um certo género
freqPorGenero(Genero, MediaFreq) :-
    % Recolhe todas as frequências de atividade física dess género
    % e junta numa lista
    findall(Freq, (
        estudante(Id, _, Genero), 
        atividade(Id,_ ,_, Freq )
    ), 
    ListaFreq),
    media(ListaFreq, MediaFreq).        % Calcula a media dessa lista


% Devolve uma lista ordenada de IDs de alunos que tem saúde 'Fraca'
% e os seus valores de sono, exercício e saúde mental são inferiores 
% aos valores dados
alertaSaude(HorasSono, Exercicio, SaudeMental, ListaAlunos) :-
    % Recolhe os IDs dos alunos em risco de saúde e 
    % junta-os numa lista
    findall(Id, (
        estudante(Id, _, _), 
        saude(Id, HorasSonoEstudante, fraca, ExercicioEstudante, SaudeMentalEstudante),
        HorasSonoEstudante < HorasSono, 
        ExercicioEstudante < Exercicio, 
        SaudeMentalEstudante < SaudeMental
    ), ListaAlunosDesordenada),
    sort(ListaAlunosDesordenada, ListaAlunos).      % Ordena e remove IDs duplicados


% Calcula a probabilidade de um aluno com tempo de ecrã maior do que 
% HorasEcra ter uma nota maior do que Nota
probEcraNotasAltas(HorasEcra, Nota, Probabilidade) :-
    % Recolhe os IDs de todos Alunos que tem a nota do 
    % exame maior do que Nota e tempo de ecrã maior do que 
    % HorasEcra (Casos Favoráveis)
    findall(Id, (
        estudante(Id, _, _), 
        exame(Id, NotaEstudante), NotaEstudante > Nota, 
        atividade(Id, _, HorasEcraEstudante, _), HorasEcraEstudante > HorasEcra
    ),    ListaFavoraveis),
    length(ListaFavoraveis, NumFavoraveis),
    
    % Recolhe os IDs de todos os alunos que tem tempo de ecrã
    % maior do que HorasEcra (Casos Possíveis)
    findall(Id, (
        estudante(Id, _, _),
        atividade(Id, _, HorasEcraEstudante, _), HorasEcraEstudante > HorasEcra
    ),    ListaPossiveis),
    length(ListaPossiveis, NumPossiveis),
    
    % Probabilidade é a divisão dos 2 números se o número de casos 
    % possíveis não for 0
    (NumPossiveis > 0 -> Probabilidade1 is NumFavoraveis / NumPossiveis; Probabilidade1 = 0),
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
%------------------------------------------------------------------------------------------------------------------------------------------

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
%------------------------------------------------------------------------------------------------------------------------------------------


maratonaFilmes(ListaFilmes, ListaRestricoes, Programacao):-
    completaComEmpty(ListaFilmes, ListaCom7Filmes),
    findall(Programacao1,(
        permutation(ListaCom7Filmes, Programacao1), 
        verificaRestricoes(ListaRestricoes,Programacao1)
    ), ListaComRepetidos),
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
