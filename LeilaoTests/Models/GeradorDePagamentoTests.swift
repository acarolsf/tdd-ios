//
//  GeradorDePagamentoTests.swift
//  LeilaoTests
//
//  Created by Ana Carolina on 11/12/20.
//  Copyright © 2020 Alura. All rights reserved.
//

import XCTest
@testable import Leilao
import Cuckoo

class GeradorDePagamentoTests: XCTestCase {
    
    var daoFalso: MockLeilaoDao!
    var avaliadorFalso: Avaliador!
    var pagamentos: MockRepositorioDePagamento!
    
    override func setUp() {
        super.setUp()
        
        daoFalso = MockLeilaoDao().withEnabledSuperclassSpy()
        avaliadorFalso = Avaliador() // MockAvaliador().withEnabledSuperclassSpy()
        pagamentos = MockRepositorioDePagamento().withEnabledSuperclassSpy()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testDeveGerarPagamentoParaUmLeilaoEncerrado() {
        
        let playstation = CriadorDeLeilao().para(descricao: "Playstation")
            .lance(Usuario(nome: "José"), 2000.0)
            .lance(Usuario(nome: "Maria"), 2500.0)
            .constroi()
        
//        let daoFalso = MockLeilaoDao().withEnabledSuperclassSpy()
//        let avaliadorFalso = Avaliador() // MockAvaliador().withEnabledSuperclassSpy()
//        let pagamentos = MockRepositorioDePagamento().withEnabledSuperclassSpy()
        
        stub(daoFalso) { (daoFalso) in
            when(daoFalso.encerrados()).thenReturn([playstation])
        }
        
//        stub(avaliadorFalso) { (avaliadorFalso) in
//            when(avaliadorFalso.maiorLance()).thenReturn(2500.0)
//        }
         
        let geradorDePagamento = GeradorDePagamento(daoFalso, avaliadorFalso, pagamentos)
        geradorDePagamento.gera()
        
        let capturadorDeArgumento = ArgumentCaptor<Pagamento>()
        
        verify(pagamentos).salva(capturadorDeArgumento.capture())
        
        let pagamentoGerado = capturadorDeArgumento.value
        
        XCTAssertEqual(2500.0, pagamentoGerado?.getValor())
    }
    
    func testDeveEmpurrarParaProximoDiaUtil() {
        let iphone = CriadorDeLeilao().para(descricao: "iPhone")
            .lance(Usuario(nome: "José"), 2000.0)
            .lance(Usuario(nome: "Maria"), 2500.0)
            .constroi()
        
        stub(daoFalso) { (daoFalso) in
            when(daoFalso.encerrados()).thenReturn([iphone])
        }
        
        let formatador = DateFormatter()
        formatador.dateFormat = "yyyy/MM/dd"
        
        guard let dataAntiga = formatador.date(from: "2018/05/19") else { return }
        
        let geradorDePagamento = GeradorDePagamento(daoFalso, avaliadorFalso, pagamentos, dataAntiga)
        geradorDePagamento.gera()
        
        let capturadorDeArgumento = ArgumentCaptor<Pagamento>()
        
        verify(pagamentos).salva(capturadorDeArgumento.capture())
        
        let pagamentoGerado = capturadorDeArgumento.value
        
        let formatadorDeData = DateFormatter()
        formatadorDeData.dateFormat = "ccc"
        
        guard let dataDoPagamento = pagamentoGerado?.getData() else { return }
        
        let diaDaSemana = formatadorDeData.string(from: dataDoPagamento)
        
        XCTAssertEqual("Mon", diaDaSemana)
        
    }
}

