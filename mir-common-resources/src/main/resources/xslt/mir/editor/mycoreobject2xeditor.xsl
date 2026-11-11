<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcracl="http://www.mycore.de/xslt/acl"
  xmlns:mcrclassification="http://www.mycore.de/xslt/classification"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:include href="resource:xslt/default-parameters.xsl" />
  <xsl:include href="xslInclude:functions" />

  <!-- overwrite xsl:output of generatePage.xsl -->
  <xsl:output method="xml" encoding="UTF-8" media-type="application/xml" doctype-public="MCRXML" doctype-system="mycoreobject.dtd"/>

  <xsl:attribute-set name="tag">
    <xsl:attribute name="class">
      <xsl:value-of select="./@class" />
    </xsl:attribute>
    <xsl:attribute name="heritable">
      <xsl:value-of select="./@heritable" />
    </xsl:attribute>
    <xsl:attribute name="notinherit">
      <xsl:value-of select="./@notinherit" />
    </xsl:attribute>
  </xsl:attribute-set>

  <xsl:template match="/">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="/mycoreobject" priority="10">
    <xsl:copy>
      <xsl:for-each select="@*">
        <xsl:copy />
      </xsl:for-each>
      <!-- check the WRITEDB permission -->
      <xsl:if test="not(@ID) or mcracl:check-permission(@ID,'writedb')">
        <xsl:if test="structure/parents/parent">
          <structure>
            <parents class="MCRMetaLinkID">
              <xsl:apply-templates select="structure/parents/parent" mode="editor" />
            </parents>
          </structure>
        </xsl:if>
        <metadata xml:lang="de">
          <!-- 
            only copy element for editor not inherited from parent
          -->
          <xsl:for-each select="metadata/*[*/@inherited='0']">
            <xsl:copy use-attribute-sets="tag">
              <xsl:apply-templates select="*[@inherited='0']" mode="editor" />
            </xsl:copy>
            <xsl:value-of select="'&#x0A;'" />
          </xsl:for-each>
        </metadata>
        <xsl:copy-of select="service" />
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*[../@class='MCRMetaClassification']" mode="editor" priority="1">
    <xsl:copy>
      <xsl:for-each select="@*">
        <xsl:copy />
      </xsl:for-each>
      <xsl:attribute name="editor.output">
        <xsl:variable name="category" select="mcrclassification:category(@classid, @categid)" />
        <xsl:value-of select="mcrclassification:current-label-text($category)" />
      </xsl:attribute>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*[../@class='MCRMetaLinkID']" mode="editor" priority="1">
    <xsl:copy>
      <xsl:for-each select="@*">
        <xsl:copy />
      </xsl:for-each>
      <xsl:attribute name="editor.output">
        <xsl:variable name="mcrobj" select="document(concat('mcrobject:',@xlink:href))" />
        <xsl:apply-templates select="$mcrobj/mycoreobject" mode="resulttitle" />
      </xsl:attribute>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*[../@class]" mode="editor" priority="0">
    <xsl:copy-of select="." />
  </xsl:template>


  <xsl:template match="/mycoreobject" mode="resulttitle" priority="0">
    <xsl:value-of select="@ID" />
  </xsl:template>

</xsl:stylesheet>
