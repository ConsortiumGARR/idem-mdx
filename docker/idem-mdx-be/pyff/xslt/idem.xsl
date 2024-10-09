<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata">

    <!-- Definisci il parametro Name che può essere passato dall'esterno -->
    <xsl:param name="Name"/>

    <!-- Template per copiare l'elemento radice md:EntitiesDescriptor con i namespace necessari -->
    <xsl:template match="md:EntitiesDescriptor">
        <xsl:element name="md:EntitiesDescriptor" namespace="urn:oasis:names:tc:SAML:2.0:metadata">
            <!-- Mantieni i namespace necessari e rimuovi quelli non utilizzati -->
            <xsl:copy-of select="namespace::*[
                not(
                    name()='xrd' or 
                    name()='pyff' or 
                    name()='xs' or 
                    name()='xsi' or 
                    name()='ser' or 
                    name()='eidas' or 
                    name()='ti' or 
                    name()='xenc'
                )]"/>	
	    <!-- Copia gli attributi modificando il Name con il valore passato -->
            <xsl:copy-of select="@*[name() != 'Name']"/>
            <xsl:attribute name="Name">
                <xsl:value-of select="$Name"/>
            </xsl:attribute>
            <!-- Processa i nodi figli -->
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <!-- Template generico per copiare tutti gli altri elementi e attributi -->
    <xsl:template match="*">
        <xsl:element name="{name()}" namespace="{namespace-uri()}">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>