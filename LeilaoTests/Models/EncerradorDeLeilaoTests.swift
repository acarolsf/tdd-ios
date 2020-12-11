//
//  EncerradorDeLeilaoTests.swift
//  LeilaoTests
//
//  Created by Ana Carolina on 11/12/20.
//  Copyright © 2020 Alura. All rights reserved.
//

import XCTest
@testable import Leilao
import Cuckoo

class EncerradorDeLeilaoTests: XCTestCase {

    var formatador: DateFormatter!
    var encerradorDeLeilao: EncerradorDeLeilao!
    var daoFalso : MockLeilaoDao!
    var carteiroFalso : MockCarteiro!
    
    override func setUp() {
        super.setUp()
        
        formatador = DateFormatter()
        formatador.dateFormat = "yyyy/MM/dd"
        
        daoFalso = MockLeilaoDao().withEnabledSuperclassSpy()
        carteiroFalso = MockCarteiro().withEnabledSuperclassSpy()
        
        encerradorDeLeilao = EncerradorDeLeilao(daoFalso, carteiroFalso)
        
        
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testDeveEncerrarLeiloesQueComecaramUmaSemanaAntes() {
        
        guard let dataAntiga = formatador.date(from: "2018/05/09") else { return }
        
        let tvLed = CriadorDeLeilao().para(descricao: "TV Led").naData(data: dataAntiga).constroi()
        
        let geladeira = CriadorDeLeilao().para(descricao: "Geladeira").naData(data: dataAntiga).constroi()
        
        let leiloesAntigos = [tvLed, geladeira]
        
//        let daoFalso = MockLeilaoDao().withEnabledSuperclassSpy()
//        dao.salva(tvLed)
//        dao.salva(geladeira)
        
        stub(daoFalso) { (daoFalso) in
            when(daoFalso.correntes()).thenReturn(leiloesAntigos)
        }
        
//        encerradorDeLeilao = EncerradorDeLeilao(daoFalso)
        encerradorDeLeilao.encerra()
        
//        let leiloesEncerrados = daoFalso.encerrados()
        
        guard let statusTvLed = tvLed.isEncerrado() else { return }
        guard let statusGeladeira = geladeira.isEncerrado() else { return }
        
        XCTAssertEqual(2, encerradorDeLeilao.getTotalEncerrados())
        XCTAssertTrue(statusTvLed)
        XCTAssertTrue(statusGeladeira)
    }

    
    func testDeveAtualizarLeiloesEncerrados() {
        guard let dataAntiga = formatador.date(from: "2018/05/19") else { return }
        
        let tvLed = CriadorDeLeilao().para(descricao: "TV Led").naData(data: dataAntiga).constroi()
        
//        let daoFalso = MockLeilaoDao().withEnabledSuperclassSpy()
        
        stub(daoFalso) { (daoFalso) in
            when(daoFalso.correntes()).thenReturn([tvLed])
        }
        
//        encerradorDeLeilao = EncerradorDeLeilao(daoFalso)
        encerradorDeLeilao.encerra()
        
        
        
        verify(daoFalso).atualiza(leilao: tvLed)
    }
    
    func testDeveContinuarExecucaoMesmoQuandoDaoFalha() {
        guard let dataAntiga = formatador.date(from: "2018/05/19") else { return }
        
        let tvLed = CriadorDeLeilao().para(descricao: "TV Led").naData(data: dataAntiga).constroi()
        let geladeira = CriadorDeLeilao().para(descricao: "Geladeira").naData(data: dataAntiga).constroi()
        
        let error = NSError(domain: "Error", code: 0, userInfo: nil)
        
        stub(daoFalso) { (daoFalso) in
            when(daoFalso.correntes()).thenReturn([tvLed, geladeira])
            when(daoFalso.atualiza(leilao: tvLed)).thenThrow(error)
        }
        
        encerradorDeLeilao.encerra()
        
        verify(daoFalso).atualiza(leilao: geladeira)
        verify(carteiroFalso).envia(geladeira)
        
        // Vai falhar
//        verify(carteiroFalso).envia(tvLed)
    }
}

extension Leilao : Matchable {
    public var matcher: ParameterMatcher<Leilao> {
        return equal(to: self)
    }
}
