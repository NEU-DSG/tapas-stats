<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns="http://www.w3.org/1999/xhtml"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:eg="http://www.tei-c.org/ns/Examples"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:wfn="http://www.wwp.northeastern.edu/ns/functions"
  exclude-result-prefixes="#all">

  <xsl:variable name="apos" select='"&apos;"'/>
  <xsl:variable name="filePath" select="document-uri(/)"/>
  <xsl:variable name="fn" select="replace( tokenize( $filePath,'/' )[last()],'(\.xml|\.tei)$','')"/>

  <xsl:variable name="nonWordChars" select="concat($apos,'’(),.?!;:')"/>
  <xsl:variable name="teiHeader.string" select="normalize-space( /TEI/teiHeader )"/>
  <xsl:variable name="text.string" select="normalize-space( /TEI/text )"/>
  <xsl:variable name="TEI.string" select="normalize-space( /TEI )"/>

  <xsl:function name="wfn:num" as="xs:string">
    <xsl:param name="value" as="xs:integer"/>
    <xsl:value-of select="format-number( $value, '###,###,###' )"/>
  </xsl:function>
  
  <xsl:template match="/">
    <html>
      <head>
        <title>simple stats</title>
      </head>
      <body>
        <h1>Simple Statistics for <xsl:value-of select="$fn"/></h1>
        <table border="1">
          <thead>
            <tr>
              <td>feature</td>
              <td>teiHeader</td>
              <td>text</td>
              <td>total</td>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>elements containing text</td>
              <td><xsl:value-of select="wfn:num( count( /TEI/teiHeader//*[child::text()[not(normalize-space(.) eq '' )]] ) )"/></td>
              <td><xsl:value-of select="wfn:num( count( /TEI/text//*[child::text()[not(normalize-space(.) eq '' )]] ) )"/></td>
              <td><xsl:value-of select="wfn:num( count( //*[child::text()[not(normalize-space(.) eq '' )]] ) )"/></td>
            </tr>
            <tr>
              <td>elements, empty</td>
              <td><xsl:value-of select="wfn:num( count( /TEI/teiHeader//*[not( child::node() )] ) )"/></td>
              <td><xsl:value-of select="wfn:num( count( /TEI/text//*[not( child::node() )] ) )"/></td>
              <td><xsl:value-of select="wfn:num( count( //*[not( child::node() )] ) )"/></td>
            </tr>
            <tr>
              <td>elements, total</td>
              <td><xsl:value-of select="wfn:num( count( /TEI/teiHeader//* ) )"/></td>
              <td><xsl:value-of select="wfn:num( count( /TEI/text//* ) )"/></td>
              <td><xsl:value-of select="wfn:num( count( //* ) )"/></td>
            </tr>
            <tr>
              <td>attributes</td>
              <td><xsl:value-of select="wfn:num( count( /TEI/teiHeader//@* ) )"/></td>
              <td><xsl:value-of select="wfn:num( count( /TEI/text//@* ) )"/></td>
              <td><xsl:value-of select="wfn:num( count( //@* ) )"/></td>
            </tr>
            <tr>
              <td>content characters</td>
              <td><xsl:value-of select="wfn:num( string-length( $teiHeader.string ) )"/></td>
              <td><xsl:value-of select="wfn:num( string-length( $text.string ) )"/></td>
              <td><xsl:value-of select="wfn:num( string-length( $TEI.string ) )"/></td>
            </tr>
            <tr>
              <td>content tokens</td>
              <td><xsl:value-of select="wfn:num( count( tokenize( $teiHeader.string,' ' ) ) )"/></td>
              <td><xsl:value-of select="wfn:num( count( tokenize( $text.string,' ') ) )"/></td>
              <td><xsl:value-of select="wfn:num( count( tokenize( $TEI.string,' ') ) )"/></td>
            </tr>
            <tr>
              <td>content “words”</td>
              <td>
                <xsl:call-template name="try-to-count-words">
                  <xsl:with-param name="startHere" select="/TEI/teiHeader"/>
                </xsl:call-template>
              </td>
              <td>
                <xsl:call-template name="try-to-count-words">
                  <xsl:with-param name="startHere" select="/TEI/text"/>
                </xsl:call-template>
              </td>
              <td>
                <xsl:call-template name="try-to-count-words">
                  <xsl:with-param name="startHere" select="/TEI"/>
                </xsl:call-template>
              </td>
            </tr>
          </tbody>
        </table>
  
        <xsl:variable name="allWords"
          select='//(p|l)//text()/tokenize(translate(.,$nonWordChars,""),"\W+")[.!=""]'/>
        <xsl:variable name="saidWords"
          select='//(p|l)//text()[ancestor::said|ancestor::q|ancestor::quote]/tokenize( translate(.,$nonWordChars,""),"\W+")[.!=""]'/>
        <xsl:variable name="narrWords"
          select='//(p|l)//text()[not(ancestor::said|ancestor::q|ancestor::quote)]/tokenize( translate(.,$nonWordChars,""),"\W+")[.!=""]'/>
        <table border="2">
          <h2>as of <xsl:value-of select="current-dateTime()"/></h2>
          <thead>
            <tr style="background-color: #E5E5E5;">
              <td style="color: red;">direct speech (i.e., in <tt>&lt;said></tt>, <tt>&lt;q></tt>, or <tt>&lt;quote></tt>)</td>
              <td style="color: blue;">narrative voice (i.e., not in <tt>&lt;said></tt>, <tt>&lt;q></tt>, or <tt>&lt;quote></tt>)</td>
              <td style="color: purple;">both</td>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td style="vertical-align: top; color: red;">
                <xsl:call-template name="do-the-work">
                  <xsl:with-param name="words" select="$saidWords"/>
                </xsl:call-template>
              </td>
              <td style="vertical-align: top; color: blue;">
                <xsl:call-template name="do-the-work">
                  <xsl:with-param name="words" select="$narrWords"/>
                </xsl:call-template>
              </td>
              <td style="vertical-align: top; color: purple;">
                <xsl:call-template name="do-the-work">
                  <xsl:with-param name="words" select="$allWords"/>
                </xsl:call-template>
              </td>
            </tr>
          </tbody>
        </table>
      </body>
    </html>
  </xsl:template>
  
  <xsl:template match="@*|comment()|processing-instruction()" mode="words"/>
  <xsl:template match="*" mode="words">
    <xsl:apply-templates mode="words"/>
  </xsl:template>
  <xsl:template match="text()" mode="words">
    <xsl:variable name="prev-nob" select="preceding-sibling::*[1]
      [
        ( self::cb | self::gb | self::lb | self::pb | self::milestone )
        [ @break eq 'no']
      ]"/>
      <xsl:variable name="foll-nob" select="preceding-sibling::*[1]
        [
        ( self::cb | self::gb | self::lb | self::pb | self::milestone )
        [ @break eq 'no']
        ]"/>
    <xsl:choose>
      <xsl:when test="$prev-nob  and  $foll-nob">
        <xsl:value-of select="replace( .,'^\s-+(.*)\s+$','$1')"/>
      </xsl:when>
      <xsl:when test="$prev-nob">
        <xsl:value-of select="replace( .,'^\s-+','')"/>
      </xsl:when>
      <xsl:when test="$foll-nob">
        <xsl:value-of select="replace( .,'\s+$','')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="fw" mode="words"/>
  <xsl:template match="cb|gb|lb|pb|milestone" mode="words">
    <xsl:choose>
      <xsl:when test="@break eq 'no'"/>
      <xsl:otherwise>&#x20;</xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="try-to-count-words">
    <xsl:param name="startHere" as="node()"/>
    <xsl:variable name="wordString">
      <xsl:apply-templates select="$startHere" mode="words"/>
    </xsl:variable>
    <xsl:variable name="hyphenEnding" select="count( $startHere//text()[matches(.,'[-&#xAD;]\s*$')] )"/>
    <xsl:value-of select="wfn:num( count( tokenize( normalize-space( $wordString ),' ' ) ) - $hyphenEnding )"/>
  </xsl:template>

  <xsl:template name="do-the-work">
    <xsl:param name="words"/>
    <xsl:variable name="numWords" select="count( $words )"/>
    <h3>number of “words”: <xsl:value-of select="format-number( $numWords,'###,###,###')"/></h3>
    <table border="1" style="color: inherit; padding: 1em 1em 1em 1em;">
      <xsl:for-each-group group-by="." select="for $w in $words return lower-case($w)">
        <xsl:sort select="count(current-group())" order="descending"/>
        <tr>
          <td>
            <xsl:value-of select="current-grouping-key()"/>
          </td>
          <td>
            <xsl:value-of select="count(current-group())"/>
          </td>
          <td>
            <xsl:value-of select="format-number( count( current-group()) div $numWords, '#0.##%')"/>
          </td>
        </tr>
      </xsl:for-each-group>
    </table>
  </xsl:template>

</xsl:stylesheet>
