<?xml version="1.0" encoding="UTF-8"?>

<!-- 
  Displays a table of contents as <div id="toc" /> 
  There are multiple toc layouts defined in toc-layouts.xml.
  The toc layout to use is defined in
    /mycoreobject/service/servflags/servflag[@type='tocLayout']
  There are custom toc layout templates for HTML display of 
  toc levels and publications in custom-toc-layouts.xsl
-->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:encoder="xalan://java.net.URLEncoder"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  exclude-result-prefixes="mcrxsl encoder mods xalan i18n">
  
  <xsl:import href="xslImport:modsmeta:toc/mycoreobject-toc.xsl" />

  <xsl:param name="WebApplicationBaseURL" />
  <xsl:param name="toc.debug" />
  
  <!-- custom layouts of level items and publications -->
  <xsl:include href="toc/custom-toc-layouts.xsl" />

  <!-- load configured toc layouts -->
  <xsl:variable name="toc-layouts" select="document('resource:toc-layouts.xml')/toc-layouts" />

  <xsl:template match="/">

    <!-- query to find all objects below this one (children, grand-children) -->
    <xsl:variable name="q">
      <xsl:text>ancestor:</xsl:text><xsl:value-of select="mycoreobject/@ID" />
      <xsl:text> AND (</xsl:text>
      <xsl:text>state:</xsl:text>
      <xsl:choose>
        <xsl:when test="mcrxsl:isCurrentUserInRole('admin')">*</xsl:when>
        <xsl:when test="mcrxsl:isCurrentUserInRole('editor')">*</xsl:when>
        <xsl:otherwise>published OR createdby:<xsl:value-of select="$CurrentUser" /></xsl:otherwise>
      </xsl:choose>
      <xsl:text>)</xsl:text>
    </xsl:variable>

    <!-- get service flag that defines the toc layout to use -->
    <xsl:variable name="layoutID">
      <xsl:value-of select="mycoreobject/service/servflags/servflag[@type='tocLayout']/text()" />
    </xsl:variable>
  
    <!-- for the matching toc layout, build solr parametes to get a toc via json facet api -->
    <xsl:variable name="solr.params">
      <xsl:for-each select="$toc-layouts/toc-layout[(@id=$layoutID) or (@id=../@default)][1]">
        <xsl:text>sort=</xsl:text>
        <xsl:apply-templates select="descendant::*[@field][@order]" mode="sort" />
        <xsl:text>&amp;tocLayout=</xsl:text>
        <xsl:value-of select="@id" />
        <xsl:text>&amp;json.facet={</xsl:text>
        <xsl:call-template name="publications.json" />
        <xsl:apply-templates select="level" mode="json" />
        <xsl:text>}</xsl:text>
      </xsl:for-each>
    </xsl:variable>

    <!-- build uri to get response from solr -->
    <xsl:variable name="uri1">
      <xsl:text>solr:</xsl:text> 
      <xsl:text>q=</xsl:text><xsl:value-of select="encoder:encode($q)" />
      <xsl:text>&amp;fl=*</xsl:text> <!-- would be better to only specify fields used here -->
      <xsl:text>&amp;rows=1000</xsl:text> <!-- table of contents with more than 1.000 publications will fail -->
      <xsl:text>&amp;</xsl:text><xsl:value-of select="$solr.params" />
    </xsl:variable>
 
    <!-- transform response to simpler xml, to further simplify transformation to html -->
    <xsl:variable name="uri2">
      <xsl:text>xslStyle:toc/solr-facets2toc:</xsl:text> 
      <xsl:value-of select="$uri1" />
    </xsl:variable>

    <xsl:if test="$toc.debug='true'">
      <div id="toc" class="detail_block">
        <textarea style="width:100%;" rows="5">
          <xsl:value-of select="$solr.params" />
        </textarea>
        <textarea style="width:100%;" rows="10">
          <xsl:copy-of select="document($uri1)" />
        </textarea>
        <textarea style="width:100%;" rows="10">
          <xsl:copy-of select="document($uri2)" />
        </textarea>
      </div>
    </xsl:if>

    <!-- if the response returned any documents, show a table of contents now -->
    <xsl:for-each select="document($uri2)/toc[//doc]">
      <div id="toc" class="detail_block">
        <h3>
          <xsl:value-of select="i18n:translate('mir.metadata.content')"/>

          <!-- links to expand/collapse all toc levels at once -->
          <xsl:if test="not(toc/level[count(item)=1][item[not(level)][publications]])">          
            <span class="pull-right" style="font-size:smaller;">
              <a id="tocShowAll" href="#">
                <xsl:value-of select="i18n:translate('mir.abstract.showGroups')" />
              </a>
              <a id="tocHideAll" href="#" style="display:none;">
                <xsl:value-of select="i18n:translate('mir.abstract.hideGroups')" />
              </a>
            </span>
          </xsl:if>
        </h3>
        
        <!-- show all toc levels and publications  -->
        <xsl:apply-templates select="level|publications" />
        
        <xsl:call-template name="toc.javascript" />
      </div>
    </xsl:for-each>
    
    <xsl:apply-imports />
  </xsl:template>
  
  <!-- javascript to expand/collapse toc levels on click -->
  <xsl:template name="toc.javascript">
    <script>
      jQuery('#tocShowAll').click( function() {
        jQuery(this).hide();
        jQuery('.collapse').collapse('show'); 
        jQuery('#tocHideAll').show();
        return false;
      } );
      jQuery('#tocHideAll').click( function() {
        jQuery(this).hide();
        jQuery('.collapse').collapse('hide'); 
        jQuery('#tocShowAll').show();
        return false;
      } );
    
      jQuery('.below').each(function(index) {
        jQuery(this).on('shown.bs.collapse', function (evt) {
          if(jQuery(this).is(evt.target)) {
            jQuery(this).parent().find("a > span.toggle-collapse").first().removeClass('fa-chevron-right').addClass('fa-chevron-down');
          }
        } );            
        jQuery(this).on('hidden.bs.collapse', function (evt) {
          if(jQuery(this).is(evt.target)) {
            jQuery(this).parent().find("a > span.toggle-collapse").first().removeClass('fa-chevron-down').addClass('fa-chevron-right');
          }
        } );
      } );
    </script>
  </xsl:template>

  <!-- build solr param for sort order of returned documents -->  
  <xsl:template match="*" mode="sort">
    <xsl:value-of select="concat(@field,'+',@order)" />
    <xsl:if test="position() != last()">,</xsl:if>
  </xsl:template>

  <!-- build solr json for facet of publication ids at this level -->
  <xsl:template name="publications.json">
    <xsl:text>docs:{type:terms,field:id,limit:1000</xsl:text>
    <xsl:if test="level">
      <xsl:text>,domain:{filter:"</xsl:text> <!-- exclude all ids that will occur at any sub-level -->
      <xsl:for-each select="descendant::level">
        <xsl:value-of select="concat('-',@field,':[*+TO+*]')" />
        <xsl:if test="level">+AND+</xsl:if>
      </xsl:for-each>
      <xsl:text>"}</xsl:text>
    </xsl:if>
    <xsl:text>}</xsl:text>
  </xsl:template>

  <!-- build solr json for a toc level as facet -->
  <!-- preserve the default expanded state of level encoded as part of the facet name -->
  <xsl:template match="level" mode="json">
    <xsl:text>,</xsl:text>
    <xsl:value-of select="concat(@field,'_expanded_',@expanded)" />
    <xsl:text>:{type:terms,limit:100</xsl:text>
    <xsl:value-of select="concat(',field:',@field)" />
    <xsl:value-of select="concat(',sort:{index:',@order,'}')" />
    <xsl:text>,facet:{</xsl:text>
    <xsl:call-template name="publications.json" />
    <xsl:apply-templates select="level" mode="json" />
    <xsl:text>}}</xsl:text>
  </xsl:template>

  <!-- if at top level, there is only one group, without deeper levels, just show publications -->
  <xsl:template match="toc/level[count(item)=1][item[not(level)][publications]]" priority="1">
    <xsl:apply-templates select="item/publications" />
  </xsl:template>
  
  <!-- show a toc level -->
  <xsl:template match="level">
    <ol style="list-style-type: none;">
      <xsl:for-each select="item">
        
        <xsl:variable name="id" select="generate-id()" />
        
        <xsl:variable name="expanded">
          <xsl:choose>
            <xsl:when test="(../@expanded='first') and (position()=1)">true</xsl:when>
            <xsl:otherwise><xsl:value-of select="../@expanded" /></xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        
        <li>
          <xsl:choose>
            <!-- if there are deeper levels below, prepare expand/collapse functionality -->
            <xsl:when test="level|publications">
            
              <a href="#{$id}" data-toggle="collapse" aria-expanded="{$expanded}" aria-controls="{$id}" style="margin-right:1ex;">
                <span>
                  <xsl:attribute name="class">
                    <xsl:text>toggle-collapse fa fa-fw </xsl:text>
                    <xsl:choose>
                      <xsl:when test="$expanded='true'">fa-chevron-down</xsl:when>
                      <xsl:otherwise>fa-chevron-right</xsl:otherwise>
                    </xsl:choose>
                  </xsl:attribute>
                </span>
              </a>
            </xsl:when>
            <xsl:otherwise>
              <span class="fa fa-fw fa-chevron-right" style="margin-right:1ex;" />
            </xsl:otherwise>
          </xsl:choose>
          
          <!-- show this level item -->    
          <xsl:apply-templates select="." />                

          <!-- show level/publications below the current one -->
          <xsl:if test="level|publications">
            <div id="{$id}">
              <xsl:attribute name="class">
                <xsl:text>below collapse</xsl:text>
                <xsl:if test="$expanded='true'"> in</xsl:if>
              </xsl:attribute>
              <xsl:apply-templates select="level|publications" />
            </div>
          </xsl:if>
        </li>
      </xsl:for-each>
    </ol>
  </xsl:template>
  
  <!-- default template to show a toc level item (a group) -->
  <!-- may be overwritten by higher priority custom toc layout templates -->
  <xsl:template match="item">
   <span class="level.label" style="margin-right:1ex">
     <xsl:value-of select="@value" />
   </span>
   <xsl:apply-templates select="doc" />
  </xsl:template>

  <!-- show list of publications at current level -->  
  <xsl:template match="publications">
    <ul>
      <xsl:for-each select="doc">
        <xsl:sort select="@pos" data-type="number" order="ascending" />
        <li>
          <xsl:apply-templates select="." />
        </li>
      </xsl:for-each>
    </ul>
  </xsl:template>
  
  <!-- default template to show publication -->
  <!-- may be overwritten by higher priority custom toc layout templates -->
  <xsl:template match="doc">
    <a href="{$WebApplicationBaseURL}receive/{@id}">
      <xsl:value-of select="field[@name='mods.title.main']" />
    </a>
  </xsl:template>
    
</xsl:stylesheet>