/*
 * Copyright (c) 2021, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * WSO2 Inc. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
package io.ballerina.stdlib.java.jdbc.compiler;

import io.ballerina.compiler.api.symbols.ModuleSymbol;
import io.ballerina.compiler.api.symbols.Symbol;
import io.ballerina.compiler.api.symbols.SymbolKind;
import io.ballerina.compiler.api.symbols.TypeDescKind;
import io.ballerina.compiler.api.symbols.TypeReferenceTypeSymbol;
import io.ballerina.compiler.api.symbols.TypeSymbol;
import io.ballerina.compiler.api.symbols.UnionTypeSymbol;
import io.ballerina.compiler.syntax.tree.ChildNodeEntry;
import io.ballerina.compiler.syntax.tree.ExpressionNode;
import io.ballerina.compiler.syntax.tree.ModulePartNode;
import io.ballerina.compiler.syntax.tree.Node;
import io.ballerina.compiler.syntax.tree.NodeList;
import io.ballerina.compiler.syntax.tree.NonTerminalNode;
import io.ballerina.compiler.syntax.tree.RecordFieldNode;
import io.ballerina.compiler.syntax.tree.RecordFieldWithDefaultValueNode;
import io.ballerina.compiler.syntax.tree.RecordTypeDescriptorNode;
import io.ballerina.compiler.syntax.tree.SimpleNameReferenceNode;
import io.ballerina.compiler.syntax.tree.SpreadFieldNode;
import io.ballerina.compiler.syntax.tree.TypeDefinitionNode;
import io.ballerina.compiler.syntax.tree.TypedBindingPatternNode;
import io.ballerina.projects.plugins.SyntaxNodeAnalysisContext;
import io.ballerina.tools.diagnostics.Diagnostic;
import io.ballerina.tools.diagnostics.DiagnosticSeverity;
import io.ballerina.tools.diagnostics.Location;

import java.util.List;
import java.util.Optional;

/**
 * Utils class.
 */
public class Utils {

    private Utils() {
    }

    public static boolean hasCompilationErrors(SyntaxNodeAnalysisContext ctx) {
        for (Diagnostic diagnostic : ctx.compilation().diagnosticResult().diagnostics()) {
            if (diagnostic.diagnosticInfo().severity() == DiagnosticSeverity.ERROR) {
                return true;
            }
        }
        return false;
    }

    public static boolean isJDBCClientObject(SyntaxNodeAnalysisContext ctx, ExpressionNode node) {
        Optional<TypeSymbol> objectType = ctx.semanticModel().typeOf(node);
        if (objectType.isEmpty()) {
            return false;
        }
        if (objectType.get().typeKind() == TypeDescKind.UNION) {
            return ((UnionTypeSymbol) objectType.get()).memberTypeDescriptors().stream()
                    .filter(typeDescriptor -> typeDescriptor instanceof TypeReferenceTypeSymbol)
                    .map(typeReferenceTypeSymbol -> (TypeReferenceTypeSymbol) typeReferenceTypeSymbol)
                    .anyMatch(Utils::isJDBCClientObject);
        }
        if (objectType.get() instanceof TypeReferenceTypeSymbol) {
            return isJDBCClientObject(((TypeReferenceTypeSymbol) objectType.get()));
        }
        return false;
    }

    public static boolean isJDBCClientObject(TypeReferenceTypeSymbol typeReference) {
        Optional<ModuleSymbol> optionalModuleSymbol = typeReference.getModule();
        if (optionalModuleSymbol.isEmpty()) {
            return false;
        }
        ModuleSymbol module = optionalModuleSymbol.get();
        if (!(module.id().orgName().equals(Constants.BALLERINAX) && module.id().moduleName().equals(Constants.JDBC))) {
            return false;
        }
        String objectName = typeReference.definition().getName().get();
        return objectName.equals(Constants.Client.CLIENT);
    }

    public static NodeList<Node> getSpreadFieldType(SyntaxNodeAnalysisContext ctx, SpreadFieldNode spreadFieldNode) {
        List<Symbol> symbols = ctx.semanticModel().moduleSymbols();
        Object[] entries = spreadFieldNode.valueExpr().childEntries().toArray();
        ModulePartNode modulePartNode = ctx.syntaxTree().rootNode();
        ChildNodeEntry type = Utils.getVariableType(symbols, entries, modulePartNode);
        RecordTypeDescriptorNode typeDescriptor = Utils.getFirstSpreadFieldRecordTypeDescriptorNode(symbols,
                type, modulePartNode);
        typeDescriptor = Utils.getEndSpreadFieldRecordType(symbols, entries, modulePartNode,
                typeDescriptor);
        return typeDescriptor.fields();
    }

    public static ChildNodeEntry getVariableType(List<Symbol> symbols, Object[] entries,
                                                 ModulePartNode modulePartNode) {
        for (Symbol symbol : symbols) {
            if (!symbol.kind().equals(SymbolKind.VARIABLE)) {
                continue;
            }
            Optional<String> symbolName = symbol.getName();
            Optional<Node> childNodeEntry = ((ChildNodeEntry) entries[0]).node();
            if (symbolName.isPresent() && childNodeEntry.isPresent() &&
                    symbolName.get().equals(childNodeEntry.get().toString())) {
                Optional<Location> location = symbol.getLocation();
                if (location.isPresent()) {
                    Location loc = location.get();
                    NonTerminalNode node = modulePartNode.findNode(loc.textRange());
                    if (node instanceof TypedBindingPatternNode) {
                        TypedBindingPatternNode typedBindingPatternNode = (TypedBindingPatternNode) node;
                        return (ChildNodeEntry) typedBindingPatternNode.childEntries().toArray()[0];
                    }
                }
            }
        }
        return null;
    }

    public static RecordTypeDescriptorNode getFirstSpreadFieldRecordTypeDescriptorNode(List<Symbol> symbols,
                                                                                       ChildNodeEntry type,
                                                                                       ModulePartNode modulePartNode) {
        if (type != null && type.node().isPresent()) {
            for (Symbol symbol : symbols) {
                if (!symbol.kind().equals(SymbolKind.TYPE_DEFINITION)) {
                    continue;
                }
                if (symbol.getName().isPresent() &&
                        symbol.getName().get().equals(type.node().get().toString().trim())) {
                    Optional<Location> loc = symbol.getLocation();
                    if (loc.isPresent()) {
                        Location location = loc.get();
                        Node node = modulePartNode.findNode(location.textRange());
                        if (node instanceof TypeDefinitionNode) {
                            TypeDefinitionNode typeDefinitionNode = (TypeDefinitionNode) node;
                            return (RecordTypeDescriptorNode) typeDefinitionNode.typeDescriptor();
                        }
                    }
                }
            }
        }
        return null;
    }

    public static RecordTypeDescriptorNode getEndSpreadFieldRecordType(List<Symbol> symbols, Object[] entries,
                                                                       ModulePartNode modulePartNode,
                                                                       RecordTypeDescriptorNode typeDescriptor) {
        if (typeDescriptor != null) {
            for (int i = 1; i < entries.length; i++) {
                String childNodeEntry = ((ChildNodeEntry) entries[i]).node().get().toString();
                NodeList<Node> recordFields = typeDescriptor.fields();
                if (childNodeEntry.equals(".")) {
                    continue;
                }
                for (Node recordField : recordFields) {
                    String fieldName;
                    Node fieldType;
                    if (recordField instanceof RecordFieldWithDefaultValueNode) {
                        RecordFieldWithDefaultValueNode fieldWithDefaultValueNode =
                                (RecordFieldWithDefaultValueNode) recordField;
                        fieldName = fieldWithDefaultValueNode.fieldName().text().trim();
                        fieldType = fieldWithDefaultValueNode.typeName();
                    } else {
                        RecordFieldNode fieldNode = (RecordFieldNode) recordField;
                        fieldName = fieldNode.fieldName().text().trim();
                        fieldType = fieldNode.typeName();
                    }
                    if (fieldName.equals(childNodeEntry.trim())) {
                        if (fieldType instanceof SimpleNameReferenceNode) {
                            SimpleNameReferenceNode nameReferenceNode = (SimpleNameReferenceNode) fieldType;
                            for (Symbol symbol : symbols) {
                                if (!symbol.kind().equals(SymbolKind.TYPE_DEFINITION)) {
                                    continue;
                                }
                                if (symbol.getName().isPresent() &&
                                        symbol.getName().get().equals(nameReferenceNode.name().text().trim())) {
                                    Optional<Location> loc = symbol.getLocation();
                                    if (loc.isPresent()) {
                                        Location location = loc.get();
                                        Node node = modulePartNode.findNode(location.textRange());
                                        if (node instanceof TypeDefinitionNode) {
                                            TypeDefinitionNode typeDefinitionNode = (TypeDefinitionNode) node;
                                            typeDescriptor = (RecordTypeDescriptorNode) typeDefinitionNode.
                                                    typeDescriptor();
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return typeDescriptor;
    }
}
