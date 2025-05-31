//
//  File.swift
//  
//
//  Created by Martin Lalev on 28/03/2024.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxMacros

struct StorageClientServiceMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let protocolDeclaration = declaration.as(ProtocolDeclSyntax.self) else {
            return []
        }
        
        let protocolName = protocolDeclaration.name.text
        
        let protocolImplementations = protocolDeclaration.memberBlock.members
            .compactMap { try? implement(declaration: $0.decl) }
        
        let clientImplementation = try StructDeclSyntax("struct \(raw: protocolName)Client: \(raw: protocolName)") {
            DeclSyntax(stringLiteral: "private let dataStorageKey: String = UUID().uuidString")
            DeclSyntax(stringLiteral: "private let storageClient: KeyValueStorageService")
            
            try InitializerDeclSyntax("init(storageClient: KeyValueStorageService)") {
                ExprSyntax(stringLiteral: "self.storageClient = storageClient")
            }.with(\.leadingTrivia, .newlines(2))
            
            for implementedFunction in protocolImplementations {
                implementedFunction
            }
        }
        
        return [
            clientImplementation.as(DeclSyntax.self)
        ].compactMap { $0 }
    }
    
    private static func implement(declaration: DeclSyntax) throws -> VariableDeclSyntax? {
        guard let variableDeclaration = declaration.as(VariableDeclSyntax.self) else { return nil }
        
        guard let patternBinding = variableDeclaration.bindings.first?.as(PatternBindingSyntax.self) else { return nil }
        
        guard let identifierSyntax = patternBinding.pattern.as(IdentifierPatternSyntax.self) else { return nil }
        guard let typeSyntax = patternBinding.typeAnnotation?.as(TypeAnnotationSyntax.self) else { return nil }

        guard let paramType = typeSyntax.type.as(IdentifierTypeSyntax.self) else { return nil }
        
        if paramType.name.text.starts(with: "KeyValueStorageEntry") {
            guard let macroAttribute = variableDeclaration.attributes.first?.as(AttributeSyntax.self) else {
                return nil
            }
            guard let macroAttributeArguments = macroAttribute.arguments?.as(LabeledExprListSyntax.self) else {
                return nil
            }
            guard let defaultValueExpression = macroAttributeArguments.first?.expression else {
                return nil
            }

            return try VariableDeclSyntax("var \(raw: identifierSyntax.identifier.text): \(raw: typeSyntax.type.description)") {
                ExprSyntax("self.storageClient.entry(for: \"\(raw: identifierSyntax.identifier.text)\", dataStorageKey: dataStorageKey, defaultTo: \(defaultValueExpression))")
            }.with(\.leadingTrivia, .newlines(2))
        } else {
            return try VariableDeclSyntax("var \(raw: identifierSyntax.identifier.text): \(raw: typeSyntax.type.description)") {
                ExprSyntax("self.storageClient.entry(for: \"\(raw: identifierSyntax.identifier.text)\", dataStorageKey: dataStorageKey)")
            }.with(\.leadingTrivia, .newlines(2))
        }
    }
}
