<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" xmlns:mcrmods="xalan://org.mycore.mods.MCRMODSClassificationSupport"
  xmlns:acl="xalan://org.mycore.access.MCRAccessManager" xmlns:mcr="http://www.mycore.org/" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:mods="http://www.loc.gov/mods/v3" exclude-result-prefixes="xlink xalan mcr i18n acl mods mcrmods" version="1.0">

  <!--Template for result list hit: see results.xsl -->
  <xsl:template match="mcr:hit[contains(@id,'_mods_')]" priority="2">
    <xsl:param name="mcrobj" />
    <xsl:param name="mcrobjlink" />
    <xsl:variable select="100" name="DESCRIPTION_LENGTH" />
    <xsl:variable select="@host" name="host" />
    <xsl:variable name="obj_id">
      <xsl:value-of select="@id" />
    </xsl:variable>
    <xsl:variable name="mods-type">
      <xsl:choose>
        <xsl:when test="$mcrobj/metadata/def.modsContainer/modsContainer/mods:mods/mods:genre[@type='kindof']">
          <xsl:value-of
            select="substring-after($mcrobj/metadata/def.modsContainer/modsContainer/mods:mods/mods:genre[@type='kindof']/@valueURI,'#')" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates mode="mods-type" select="$mcrobj" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- TODO Schema for every type -->
    <article class="result clearfix" itemscope="" itemtype="http://schema.org/Book">

      <aside class="Vorschaubild" itemtype="http://www.schema.org/ImageObject" itemscope="" itemprop="image">
        <div class="well preview">
          <span class="number">
            <xsl:value-of select="concat(count(preceding-sibling::mcr:hit)+1,'. ')" />
          </span>
<!--           <a itemprop="url" href="images/microdata.jpg" title="Im Bildbetrachter öffnen"> -->
          <img src="{$WebApplicationBaseURL}templates/master/{$template}/IMAGES/icons_liste/icon_{$mods-type}.png" itemprop="photo"
            alt="{$mods-type}" />
<!--           </a> -->
        </div>
      </aside>
      <header class="top-head">
        <h3>
          <!-- TODO add @itemprop="url" and span -->
          <xsl:call-template name="objectLink">
            <xsl:with-param select="$mcrobj" name="mcrobj" />
          </xsl:call-template>
          
<!--           <a href="http://books.google.de/books?id=6XdJYgEACAAJ&dq=microdata&hl= -->
<!--         de&sa=X&ei=Ep76T9_3Mo74sgbbh8izDQ&redir_esc=y" -->
<!--             itemprop="url"> -->
<!--             <span itemprop="name">Analysis of -->
<!--               Microdata -->
<!--             </span> -->
<!--           </a> -->
        </h3>
      </header>
      <xsl:if test="$mcrobj/structure/parents">
        <section>
          <xsl:text>aus: </xsl:text>
          <xsl:call-template name="objectLink">
            <xsl:with-param select="$mcrobj/structure/parents/parent/@xlink:href" name="obj_id" />
          </xsl:call-template>
        </section>
      </xsl:if>
      <xsl:variable name="author"
        select="$mcrobj/metadata/def.modsContainer/modsContainer/mods:mods/mods:name[mods:role/mods:roleTerm/text()='aut']" />
      <xsl:if test="$author">
        <section>
          <span> Autor:</span>
          <xsl:for-each select="$author">
            <xsl:if test="position()!=1">
              <xsl:value-of select="'; '" />
            </xsl:if>
            <address title="Author">
              <a href="#" itemprop="author" itemscope="itemscope" itemtype="http:/schema.org/Person" rel="author">
                <span itemprop="name">
                  <xsl:apply-templates select="." mode="printName" />
                </span>
              </a>
            </address>
          </xsl:for-each>
        </section>
      </xsl:if>
      <section>
        <span>
          <xsl:value-of select="concat(i18n:translate('component.mods.metaData.dictionary.published'),': ')" />
        </span>
        
<!--         <span itmeprop="addressRegion" itemscope="itemscope" itemtype="http://schema.org/PostalAddress" title="Ort"> -->
<!--           <b>Beijing</b> -->
<!--         </span> -->
<!--         : -->
        <xsl:variable name="publisher" select="$mcrobj/metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo/mods:publisher" />
        <xsl:if test="$publisher">
          <span itemprop="publisher" itemscope="itemscope" itemtype="http://schema.org/Organize" title="Verlag">
            <xsl:value-of select="$publisher" />
          </span>
        </xsl:if>
        <xsl:if test="$mcrobj/metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo/mods:dateIssued">
          <xsl:variable name="date">
            <xsl:value-of select="$mcrobj/metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo/mods:dateIssued" />
          </xsl:variable>
          <time pubdate="pubdate" datetime="{$date}" itemprop="datePublished" title="Erschienen">
            <b>
              <xsl:value-of select="$date" />
            </b>
          </time>
        </xsl:if>
      </section>
      <!-- 
      <section>
        <span class="signature" title="Signatur">
          <span>
            Signatur :
          </span>
          <b>INF:HE:4000:HTML:Hog:2011</b>
        </span>
      </section>
       -->
      <xsl:variable name="description" select="$mcrobj/metadata/def.modsContainer/modsContainer/mods:mods/mods:abstract" />
      <xsl:if test="$description">
        <section class="summary" title="summary">
          <p itemprop="description">
            <xsl:value-of select="$description" />
          </p>
        </section>
      </xsl:if>
      <footer class="date">
        <xsl:variable name="dateModified" select="$mcrobj/service/servdates/servdate[@type='modifydate']" />
        <p>
          Zuletzt bearbeitet am :
          <time itemprop="dateModified" datetime="{$dateModified}">
            <xsl:call-template name="formatISODate">
              <xsl:with-param select="$dateModified" name="date" />
              <xsl:with-param select="i18n:translate('metaData.date')" name="format" />
            </xsl:call-template>
          </time>
        </p>
      </footer>
      <xsl:if test="$mcrobj/metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo/mods:dateIssued">
        <xsl:variable name="date">
          <xsl:value-of select="$mcrobj/metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo/mods:dateIssued" />
        </xsl:variable>
        <div class="published">
          <xsl:value-of select="concat(i18n:translate('component.mods.metaData.dictionary.dateIssued'),': ',$date)" />
        </div>
        <footer class="datum">
          <p>
            <xsl:value-of select="concat(i18n:translate('component.mods.metaData.dictionary.dateIssued'),': ')" />
            <time itemprop="dateModified" datetime="{$date}">
              <xsl:value-of select="$date" />
            </time>
          </p>
        </footer>
      </xsl:if>
      <section>
        <ul class="actions">
          <li>
            <a href="#">
              <i class="fa fa-edit"></i>
              Bearbeiten
            </a>
          </li>
          <li>
            <a
              href="{$ServletsBaseURL}MCRBasketServlet{$HttpSession}?type=objects&amp;action=add&amp;id={$mcrobj/@ID}&amp;uri=mcrobject:{$mcrobj/@ID}&amp;redirect=referer">
              <i class="fa fa-plus"></i>
              <xsl:value-of select="i18n:translate('basket.add')" />
            </a>
          </li>
        </ul>
      </section>
    </article>
  </xsl:template>


  <!--Template for title in metadata view: see mycoreobject.xsl -->
  <xsl:template priority="2" mode="fulltitle" match="/mycoreobject[contains(@ID,'_mods_')]">
    <xsl:value-of select="./metadata/def.modsContainer/modsContainer/mods:mods/mods:titleInfo/mods:title[1]" />
  </xsl:template>
  
  <!--Template for printlatestobjects: see mycoreobject.xsl, results.xsl, MyCoReLayout.xsl -->
  <xsl:template priority="2" mode="latestObjects" match="mcr:hit[contains(@id,'_mods_')]">
    <xsl:param name="mcrobj" />
    <div class="hit_item">
      <h3>
        <xsl:call-template name="objectLink">
          <xsl:with-param select="$mcrobj" name="mcrobj" />
        </xsl:call-template>
      </h3>

      <xsl:if test="$mcrobj/metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo/mods:dateIssued">
        <div class="created">
          <xsl:variable name="date">
            <xsl:call-template name="formatISODate">
              <xsl:with-param select="$mcrobj/metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo/mods:dateIssued"
                name="date" />
              <xsl:with-param select="i18n:translate('metaData.date')" name="format" />
            </xsl:call-template>
          </xsl:variable>
        <!-- xsl:value-of select="i18n:translate('results.lastChanged',$date)" / -->
          <xsl:value-of select="$date" />
        </div>
      </xsl:if>

    <!-- Authors -->
      <div class="author">
        <xsl:for-each
          select="$mcrobj/metadata/def.modsContainer/modsContainer/mods:mods/mods:name[mods:role/mods:roleTerm/text()='aut' and position() &lt; 4]">
          <xsl:if test="position()!=1">
            <xsl:value-of select="'; '" />
          </xsl:if>
          <xsl:choose>
            <xsl:when test="mods:displayForm">
              <xsl:value-of select="mods:displayForm" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="mods:namePart[@type='given']" />
              <xsl:text> </xsl:text>
              <xsl:value-of select="mods:namePart[@type='family']" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </div>
    </div>
  </xsl:template>


</xsl:stylesheet>